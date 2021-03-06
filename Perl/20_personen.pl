=head1 NAME

personen - Attempt to merge the personen table.

=head1 VERSION HISTORY

version 1.0 19 December 2013 DV

=over 4

=item *

Initial release.

=back

=head1 DESCRIPTION

Extract personen information from indicatorfiches, start with aanspreekpunt.

=head1 SYNOPSIS

 personen.pl

 personen -h	Usage
 personen -h 1  Usage and description of the options
 personen -h 2  All documentation

=head1 OPTIONS

=over 4

No inline options are available. There is a properties\vo.ini file that contains script settings.

=back

=head1 ADDITIONAL DOCUMENTATION

=cut

###########
# Variables
########### 

my ($log, $cfg, $dbs, $dbt, %names);

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
my @tables = qw (persoon);
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
	my $beleidsdomein = -1;
	my $entiteit = -1;
	my $afdeling = -1;
	my @fields = qw (organisatie_id beleidsdomein entiteit afdeling);
    my (@vals) = map { eval ("\$" . $_ ) } @fields;
	unless (create_record($dbt, "organisatie", \@fields, \@vals)) {
		$log->fatal("Could not insert record into organisatie");
		exit_application(1);
	}
}

# Get personen information
my @fields = qw (ldap naam voornaam);
$query = "SELECT ldap_id, naam, voornaam
		  FROM ldap";
$ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my $ldap = lc($$record{ldap_id});
	my $naam = $$record{naam};
	my $voornaam = $$record{voornaam};
    my (@vals) = map { eval ("\$" . $_ ) } @fields;
	unless (create_record($dbt, "persoon", \@fields, \@vals)) {
		$log->fatal("Could not insert record into persoon");
		exit_application(1);
	}
    my $fullname = "$voornaam $naam";
	$names{$fullname} = 1;
}

# Check for -1 record in persoon
$query = "SELECT count(persoon_id) rec_count 
          FROM persoon
	      WHERE persoon_id = -1";
$ref = do_select($dbt, $query);
$record = @$ref[0];
$rec_cnt = $$record{'rec_count'};
if ($rec_cnt == 0) {
	my $persoon_id = -1;
	my $naam = "(geen naam)";
	my @fields = qw (persoon_id naam);
    my (@vals) = map { eval ("\$" . $_ ) } @fields;
	unless (create_record($dbt, "persoon", \@fields, \@vals)) {
		$log->fatal("Could not insert record into persoon");
		exit_application(1);
	}
}

@fields = qw (voornaam naam);

$log->info("Get Aanspreekpunt");
$query = "SELECT distinct aanspreekpunt 
          FROM indicatorfiches
    	  WHERE aanspreekpunt is not null";
$ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my ($naam);
	my $aanspreekpunt = $$record{'aanspreekpunt'};
	if (index($aanspreekpunt, "/") > -1) {
		($aanspreekpunt, undef) = split /\//, $aanspreekpunt;
	}
	my ($voornaam, $fam1, $fam2) = split / /, $aanspreekpunt;
	if (defined $fam2) {
		$naam = "$fam1 $fam2";
	} else {
		$naam = $fam1;
	}
    my $fullname = "$voornaam $naam";
	if (not (exists $names{$fullname})) {
		$names{$fullname} = 1;
	    my (@vals) = map { eval ("\$" . $_ ) } @fields;
	    unless (create_record($dbt, "persoon", \@fields, \@vals)) {
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
