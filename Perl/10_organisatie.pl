=head1 NAME

organisatie - Attempt to merge the organisatie table.

=head1 VERSION HISTORY

version 1.0 19 December 2013 DV

=over 4

=item *

Initial release.

=back

=head1 DESCRIPTION

Extract organisatie information from indicatorfiches, start with aanspreekpunt.

=head1 SYNOPSIS

 organisatie.pl

 organisatie -h	Usage
 organisatie -h 1  Usage and description of the options
 organisatie -h 2  All documentation

=head1 OPTIONS

=over 4

No inline options are available. There is a properties\vo.ini file that contains script settings.

=back

=head1 ADDITIONAL DOCUMENTATION

=cut

###########
# Variables
########### 

my ($log, $cfg, $dbs, $dbt, %v_entiteit, %v_afdeling, %organisaties);

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
use DbUtil qw(db_connect do_select create_record);

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

# Delete tables in sequence
my @tables = qw (persoon organisatie);
foreach my $table (@tables) {
	if ($dbt->do("delete from $table")) {
		$log->debug("Contents of table $table deleted");
	} else {
		$log->fatal("Failed to delete `$table'. Error: " . $dbt->errstr);
		exit_application(1);
	}
}

# Check for -1 record in organisatie
my $query = "SELECT count(organisatie_id) rec_count 
             FROM organisatie
			 WHERE organisatie_id = -1";
my $ref = do_select($dbt, $query);
my $record = @$ref[0];
my $rec_cnt = $$record{'rec_count'};
if ($rec_cnt == 0) {
	my $organisatie_id = -1;
	my $beleidsdomein = "(geen organisatie)";
	my @fields = qw (organisatie_id beleidsdomein);
    my (@vals) = map { eval ("\$" . $_ ) } @fields;
	unless (create_record($dbt, "organisatie", \@fields, \@vals)) {
		$log->fatal("Could not insert record into organisatie");
		exit_application(1);
	}
}

# Get vertaaltabel
$query = "SELECT veld, huidig, vertaling
          FROM vertaaltabel";
$ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my $veld = $$record{'veld'};
	my $huidig = lc($$record{'huidig'});
	my $vertaling = $$record{'vertaling'};
	if ($veld eq "entiteit") {
		$v_entiteit{$huidig} = $vertaling;
	} elsif ($veld eq "afdeling") {
		$v_afdeling{$huidig} = $vertaling;
	}
}

my @fields = qw (beleidsdomein entiteit afdeling);
my $beleidsdomein = "Mobiliteit en Openbare Werken";

$log->info("Get entiteit en organisatie");
$query = "SELECT distinct entiteit, afdeling 
          FROM indicatorfiches
    	  WHERE entiteit is not null";
$ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my $entiteit = lc($$record{'entiteit'});
	my $afdeling = lc($$record{'afdeling'});
	if (exists $v_entiteit{$entiteit}) {
		$entiteit = $v_entiteit{$entiteit};
	} else {
		$log->error("No entiteit translation found for $entiteit");
	}
	if (exists $v_afdeling{$afdeling}) {
		$afdeling = $v_afdeling{$afdeling};
	} else {
		$log->error("No afdeling translation found for $afdeling");
	}
    my $fullname = "$entiteit $afdeling";
	if (not (exists $organisaties{$fullname})) {
		$organisaties{$fullname} = 1;
	    my (@vals) = map { eval ("\$" . $_ ) } @fields;
	    unless (create_record($dbt, "organisatie", \@fields, \@vals)) {
		    $log->fatal("Could not insert record into persoon");
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
