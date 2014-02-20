=head1 NAME

get_geo_coords - Get Geo Object information	

=head1 VERSION HISTORY

version 1.0 18 February 2014 DV

=over 4

=item *

Initial release.

=back

=head1 DESCRIPTION

Extract Geo Coordinates from missing_links table.

=head1 SYNOPSIS

 get_geo_coords.pl

 get_geo_coords -h	Usage
 get_geo_coords -h 1  Usage and description of the options
 get_geo_coords -h 2  All documentation

=head1 OPTIONS

=over 4

No inline options are available. There is a properties\vo.ini file that contains script settings.

=back

=head1 ADDITIONAL DOCUMENTATION

=cut

###########
# Variables
########### 

my ($log, $cfg, $dbs, $dbt, %geo_object, @geom);

#####
# use
#####

use FindBin;
use lib "$FindBin::Bin/lib";

use warnings;			    # show warning messages
use strict 'vars';
use strict 'refs';
use strict 'subs';
use Getopt::Std;		    # Handle input params
use Pod::Usage;			    # Allow Usage information
use DBI();
use DbUtil qw(db_connect do_select do_stmt singleton_select create_record);

use Log::Log4perl qw(get_logger);
use SimpleLog qw(setup_logging);
use IniUtil qw(load_ini get_ini);

use Data::Dumper;

################
# Trace Warnings
################

use Carp;
$SIG{__WARN__} = sub { Carp::confess( @_ ) };

#############
# subroutines
#############

sub exit_application($) {
    my ($return_code) = @_;
	if (defined $dbs) {
		$dbs->disconnect;
	}
	if (defined $dbt) {
		$dbt->disconnect;
	}
	$log->info("Exit application with return code $return_code.");
	exit $return_code;
}

sub trim {
    my @out = @_;
    for (@out) {
        s/^\s+//;
        s/\s+$//;
    }
    return wantarray ? @out : $out[0];
}

######
# Main
######

# Handle input values
my %options;
getopts("h:", \%options) or pod2usage(-verbose => 0);
# my $arglength = scalar keys %options;  
# if ($arglength == 0) {			# If no options specified,
#	$options{"h"} = 0;			# display usage.
#}
#Print Usage
if (defined $options{"h"}) {
    if ($options{"h"} == 0) {
        pod2usage(-verbose => 0);
    } elsif ($options{"h"} == 1) {
        pod2usage(-verbose => 1);
    } else {
		pod2usage(-verbose => 2);
	}
}
# Get ini file configuration
my $ini = { project => "vo" };
$cfg = load_ini($ini);
# Start logging
setup_logging;
$log = get_logger();
$log->info("Start application");
# Show input parameters
if ($log->is_trace()) {
	while (my($key, $value) = each %options) {
		$log->trace("$key: $value");
	}
}
# End handle input values

# Make database connection for vo database
$dbs = db_connect("mow_access") or exit_application(1);
$dbt = db_connect("mow_fase1")  or exit_application(1);

# Remove geo_prev from geo_coordinaten.
# This is required to allow delete.
my $query = "UPDATE geo_coordinaten SET geo_prev = NULL";
$dbt->do($query);

# Delete tables in sequence
my @tables = qw (geo_coordinaten);
foreach my $table (@tables) {
	if ($dbt->do("delete from $table")) {
		$log->debug("Contents of table $table deleted");
	} else {
		$log->fatal("Failed to delete `$table'. Error: " . $dbt->errstr);
		exit_application(1);
	}
}

# Get naam - geo_object_id links
my $query = "SELECT naam, geo_object_id
	         FROM geo_object";
my $ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	$geo_object{$$record{naam}} = $$record{geo_object_id};
}

my @fields = qw (geo_coordinaten_id geo_object_id geo_prev geostring);
my @vals = (-1, -1, -1, "(geen coordinaten)");
unless (defined create_record($dbt, "geo_coordinaten", \@fields, \@vals)) {
	$log->fatal("Could not insert record into geo_coordinaten");
	exit_application(1);
}

@fields = qw(geo_object_id geo_prev geostring);

$log->info("Get Geo Objecten");
$query = "SELECT naam, the_geom_1, the_geom_2, the_geom_3, the_geom_4,
                 the_geom_5, the_geom_6, the_geom_7, the_geom_8
          FROM missinglinks";
$ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	undef @geom;
	my $naam = $$record{naam};
	push @geom, ($$record{the_geom_1}, $$record{the_geom_2}, 
                 $$record{the_geom_3}, $$record{the_geom_4},
				 $$record{the_geom_5}, $$record{the_geom_6},
				 $$record{the_geom_7}, $$record{the_geom_8});
	my $geo_prev = -1;
	my $geo_object_id = $geo_object{$naam};
	while (my $geostring = shift @geom) {
		if (length($geostring) == 0) {
			last;
		}
		my (@vals) = map { eval ("\$" . $_ ) } @fields;
		$geo_prev = create_record($dbt, "geo_coordinaten", \@fields, \@vals);
		if (not defined $geo_prev) {
			$log->fatal("Could not insert record into geo_coordinaten");
			exit_application(1);
		}
	}
}

exit_application(0);

=head1 To Do

=over 4

=item *

Nothing for now...

=back

=head1 AUTHOR

Any suggestions or bug reports, please contact E<lt>dirk.vermeylen@hp.comE<gt>
