=head1 NAME

Frequenties - Extract frequentie values from the Indicatorfiches.

=head1 VERSION HISTORY

version 1.0 19 December 2013 DV

=over 4

=item *

Initial release.

=back

=head1 DESCRIPTION

Extract the frequentie values from the mow_access indicatorfiche tabel.

=head1 SYNOPSIS

 frequentie.pl

 frequentie -h	Usage
 frequentie -h 1  Usage and description of the options
 frequentie -h 2  All documentation

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

# Delete existing Frequenties from referentie tabel
my $query = "DELETE FROM referentie WHERE type = 'Frequentie'";
if ($dbt->do($query)) {
	$log->debug("Frequentie deleted from referentie tabel");
} else {
	$log->fatal("Could not delete Frequentie from referentie tabel" . $dbt->errstr);
}


$log->info("Get Frequentie");

my $type = "Frequentie";
my $actief = "J";
my @fields = qw (type veld waarde actief gewicht);
my @months = ('januari', 'februari', 'maart', 'april', 'mei', 'juni', 'juli', 'augustus', 'september', 'oktober', 'november', 'december');
my $veld = "maand";
my $gewicht = 0;
foreach my $month (@months) {
	$gewicht++;
	my $waarde = $month;
    my (@vals) = map { eval ("\$" . $_ ) } @fields;
    unless (create_record($dbt, "referentie", \@fields, \@vals)) {
        $log->fatal("Could not insert record into referentie");
	    exit_application(1);
	}
}

$veld = "kwartaal";
@fields = qw (type veld waarde actief);
my @quarters = ('kwartaal 1', 'kwartaal 2', 'kwartaal 3', 'kwartaal 4');
foreach my $quart (@quarters) {
	my $waarde = $quart;
    my (@vals) = map { eval ("\$" . $_ ) } @fields;
    unless (create_record($dbt, "referentie", \@fields, \@vals)) {
        $log->fatal("Could not insert record into referentie");
	    exit_application(1);
	}
}

for (my $yr = 1980; $yr < 2031; $yr++) {
	$veld = "jaar";
	my $waarde = $yr;
    my (@vals) = map { eval ("\$" . $_ ) } @fields;
    unless (create_record($dbt, "referentie", \@fields, \@vals)) {
        $log->fatal("Could not insert record into referentie");
	    exit_application(1);
	}
	$veld = "schooljaar";
	$waarde = "$yr-" . ($yr + 1);
    (@vals) = map { eval ("\$" . $_ ) } @fields;
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
