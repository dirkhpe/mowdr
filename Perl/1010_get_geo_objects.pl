=head1 NAME

get_geo_objects - Get Geo Object information	

=head1 VERSION HISTORY

version 1.0 18 February 2014 DV

=over 4

=item *

Initial release.

=back

=head1 DESCRIPTION

Extract the Geo Object Information from missing_link table.

=head1 SYNOPSIS

 get_geo_objects.pl

 get_geo_objects -h	Usage
 get_geo_objects -h 1  Usage and description of the options
 get_geo_objects -h 2  All documentation

=head1 OPTIONS

=over 4

No inline options are available. There is a properties\vo.ini file that contains script settings.

=back

=head1 ADDITIONAL DOCUMENTATION

=cut

###########
# Variables
########### 

my ($log, $cfg, $dbs, $dbt);

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
my @tables = qw (geo_coordinaten geo_object);
foreach my $table (@tables) {
	if ($dbt->do("delete from $table")) {
		$log->debug("Contents of table $table deleted");
	} else {
		$log->fatal("Failed to delete `$table'. Error: " . $dbt->errstr);
		exit_application(1);
	}
}

my @fields = qw (naam label);

$log->info("Get Geo Objecten");
$query = "SELECT naam, label 
             FROM missinglinks";
my $ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my $naam = $$record{naam};
	my $label = $$record{label};
	my (@vals) = map { eval ("\$" . $_ ) } @fields;
	unless (create_record($dbt, "geo_object", \@fields, \@vals)) {
		$log->fatal("Could not insert record into geo_object");
		exit_application(1);
	}
}

# Add -1 identifier
@fields = qw (geo_object_id naam);
my @vals = (-1, "(geen geo_object)");
unless (create_record($dbt, "geo_object", \@fields, \@vals)) {
	$log->fatal("Could not insert record into geo_object");
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
