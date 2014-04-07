=head1 NAME

get_geo_groep - Get Geo Groep information	

=head1 VERSION HISTORY

version 1.0 27 February 2014 DV

=over 4

=item *

Initial release.

=back

=head1 DESCRIPTION

Extract Geo Groep from missing_links table.

=head1 SYNOPSIS

 get_geo_groep.pl

 get_geo_groep -h	Usage
 get_geo_groep -h 1  Usage and description of the options
 get_geo_groep -h 2  All documentation

=head1 OPTIONS

=over 4

No inline options are available. There is a properties\vo.ini file that contains script settings.

=back

=head1 ADDITIONAL DOCUMENTATION

=cut

###########
# Variables
########### 

my ($log, $cfg, $dbt, %geo_object);

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
$dbt = db_connect("mow_fase1")  or exit_application(1);

# Delete tables in sequence
my @tables = qw (geo_groep_fiche geo_status geo_object_groep geo_groep);
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
	         FROM geo_object
			 WHERE geo_object_id > 0";
my $ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	$geo_object{$$record{naam}} = $$record{geo_object_id};
}

# Add geo_groep record
my @fields = qw(naam omschrijving);
my @vals = ("Missing Links", "Verzameling van missing links");
my $geo_groep_id = create_record($dbt, "geo_groep", \@fields, \@vals);
if (not defined $geo_groep_id) {
	$log->fatal("Could not insert record into geo_groep");
	exit_application(1);
}

# Add geo_groep to geo_groep_fiche
@fields = qw(geo_groep_id indicatorfiche_id);
@vals = ($geo_groep_id, 41);
unless (defined create_record($dbt, "geo_groep_fiche", \@fields, \@vals)) {
	$log->fatal("Could not insert record into geo_groep_fiche");
	exit_application(1);
}

# Add geo_object_groep
@fields = qw(geo_object_id geo_groep_id);
while (my ($geo_name, $geo_object_id) = each %geo_object) {
	my (@vals) = map { eval ("\$" . $_ ) } @fields;
	unless (defined create_record($dbt, "geo_object_groep", \@fields, \@vals)) {
		$log->fatal("Could not insert record into geo_object_groep");
		exit_application(1);
	}
}

# Add 'Geen Groep' to geo_groep
@fields = qw(geo_groep_id naam);
@vals = (-1, "(geen groep)");
unless (defined create_record($dbt, "geo_groep", \@fields, \@vals)) {
	$log->fatal("Could not insert record into geo_groep");
	exit_application(1);
}
	
exit_application(0);

=head1 To Do

=over 4

=item *

Nothing for now...

=back

=head1 AUTHOR

Any suggestions or bug reports, please contact E<lt>dirk.vermeylen@hp.comE<gt>
