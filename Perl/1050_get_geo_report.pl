=head1 NAME

get_geo_report - Get Geo Groep information	

=head1 VERSION HISTORY

version 1.0 27 February 2014 DV

=over 4

=item *

Initial release.

=back

=head1 DESCRIPTION

Extract Geo Groep from missing_links table.

=head1 SYNOPSIS

 get_geo_report.pl

 get_geo_report -h	Usage
 get_geo_report -h 1  Usage and description of the options
 get_geo_report -h 2  All documentation

=head1 OPTIONS

=over 4

No inline options are available. There is a properties\vo.ini file that contains script settings.

=back

=head1 ADDITIONAL DOCUMENTATION

=cut

###########
# Variables
########### 

my ($log, $cfg, $dbs, $dbt, %geo_object, %geo_status);

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
$dbs = db_connect("mow_access")  or exit_application(1);
$dbt = db_connect("mow_fase1")   or exit_application(1);

# Delete tables in sequence
my @tables = qw (geo_report);
foreach my $table (@tables) {
	if ($dbt->do("delete from $table")) {
		$log->debug("Contents of table $table deleted");
	} else {
		$log->fatal("Failed to delete `$table'. Error: " . $dbt->errstr);
		exit_application(1);
	}
}

# Get geo_object links
my $query = "SELECT geo_object_id, naam
	         FROM geo_object
			 WHERE geo_object_id > -1";
my $ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	$geo_object{$$record{naam}} = $$record{geo_object_id};
}

# Get geo_status fields
$query = "SELECT geo_status_id, waarde
		  FROM geo_status
		  WHERE geo_status_id > -1";
$ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	$geo_status{$$record{waarde}} = $$record{geo_status_id};
}

my $jaar = 2013;
my ($dagnr);
# Get dagnr
$query = "SELECT min(dagnr) dagnr
		  FROM frequenties
		  WHERE jaar = $jaar";
$ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	$dagnr = $$record{dagnr};
}

my $indicatorfiche_id = 41;
my $periode = $jaar;
my $commentaar = "Migratie van POC Missing Links";
my $actief = "J";
my @fields = qw(indicatorfiche_id geo_object_id dagnr periode jaar geo_status_id commentaar actief);
# Get missing links - states from missinglink table
$query = "SELECT naam, d_staat
		  FROM missinglinks";
$ref = do_select($dbs, $query);
foreach my $record(@$ref) {
	my $geo_object_id = $geo_object{$$record{naam}};
	my $geo_status_id = $geo_status{$$record{d_staat}};
	my (@vals) = map { eval ("\$" . $_ ) } @fields;
	unless (defined create_record($dbt, "geo_report", \@fields, \@vals)) {
		$log->fatal("Could not insert record into geo_report");
		exit_application(1);
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
