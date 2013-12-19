=head1 NAME

References - Extract reference values from the Indicatorfiches.

=head1 VERSION HISTORY

version 1.0 19 December 2013 DV

=over 4

=item *

Initial release.

=back

=head1 DESCRIPTION

Extract the reference values from the mow_access indicatorfiche tabel.

=head1 SYNOPSIS

 references.pl

 references -h	Usage
 references -h 1  Usage and description of the options
 references -h 2  All documentation

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

# Delete tables in sequence
my @tables = qw (referentie);
foreach my $table (@tables) {
	if ($dbt->do("delete from $table")) {
		$log->debug("Contents of table $table deleted");
	} else {
		$log->fatal("Failed to delete `$table'. Error: " . $dbt->errstr);
		exit_application(1);
	}
}

# Initialize Referentie velden
my $type = "Keuzelijst";
my $tabel = "Indicatorfiche";
my $veld = "type_indicator";
my $actief = "J";

my @fields = qw (type tabel veld waarde actief);

$log->info("Get Type Indicator");
my $query = "SELECT `type indicator` 
             FROM `lijst types indicatoren`
			 WHERE `type indicator` is not null";
my $ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my $waarde = $$record{'type indicator'};
	my (@vals) = map { eval ("\$" . $_ ) } @fields;
	unless (create_record($dbt, "referentie", \@fields, \@vals)) {
		$log->fatal("Could not insert record into referentie");
		exit_application(1);
	}
}

$log->info("Get meeteenheid");
$veld = "meeteenheid";
$query = "SELECT distinct meeteenheid 
          FROM indicatorfiches
	      WHERE meeteenheid is not null";
$ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my $waarde = $$record{'meeteenheid'};
	my (@vals) = map { eval ("\$" . $_ ) } @fields;
	unless (create_record($dbt, "referentie", \@fields, \@vals)) {
		$log->fatal("Could not insert record into referentie");
		exit_application(1);
	}
}

$log->info("Streefwaardetype");
$veld = "Streefwaardetype";
my @types = ('geen', 'specifiek', 'default');
foreach my $streefwaarde (@types) {
	my $waarde = $streefwaarde;
	my (@vals) = map { eval ("\$" . $_ ) } @fields;
	unless (create_record($dbt, "referentie", \@fields, \@vals)) {
		$log->fatal("Could not insert record into referentie");
		exit_application(1);
	}
}

# Organisatie tabel
$tabel = "Organisatie";
$log->info("Get beleidsdomein");
$veld = "Beleidsdomein";
my $waarde = "Mobiliteit en Openbare Werken";
my (@vals) = map { eval ("\$" . $_ ) } @fields;
unless (create_record($dbt, "referentie", \@fields, \@vals)) {
	$log->fatal("Could not insert record into referentie");
	exit_application(1);
}

$log->info("Get entiteit");
$veld = "Entiteit";
$query = "SELECT distinct entiteit 
          FROM organisatie
 	      WHERE entiteit is not null";
$ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	my $waarde = $$record{'entiteit'};
	my (@vals) = map { eval ("\$" . $_ ) } @fields;
	unless (create_record($dbt, "referentie", \@fields, \@vals)) {
		$log->fatal("Could not insert record into referentie");
		exit_application(1);
	}
}

$log->info("Get afdeling");
$veld = "Afdeling";
$query = "SELECT distinct afdeling 
          FROM organisatie
 	      WHERE afdeling is not null";
$ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	my $waarde = $$record{'afdeling'};
	my (@vals) = map { eval ("\$" . $_ ) } @fields;
	unless (create_record($dbt, "referentie", \@fields, \@vals)) {
		$log->fatal("Could not insert record into referentie");
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
