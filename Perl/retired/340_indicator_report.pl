=head1 NAME

indicator_report - Map indicatorfiche to indicator information.

=head1 VERSION HISTORY

version 1.0 20 December 2013 DV

=over 4

=item *

Initial release.

=back

=head1 DESCRIPTION

Map information uit Cijferrecords to Indicatorfiche. For now, this is limited to setting the 'Aantal/Percentage' to Percentage (Neen).

=head1 SYNOPSIS

 indicator_report.pl

 indicator_report -h	Usage
 indicator_report -h 1  Usage and description of the options
 indicator_report -h 2  All documentation

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
my (%tx_indicatortabel, %tx_dimensie);
my (%fiches, %dimensies, %dim_els);

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

# Collect all translation values
my $query = "SELECT veld, huidig, vertaling
             FROM vertaaltabel
	  	     WHERE veld = 'indicatortabel'
			    OR veld = 'dimensie'";
my $ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my $huidig = $$record{'huidig'};
	my $vertaling = $$record{'vertaling'};
	my $veld = $$record{'veld'} || "";
	if ($veld eq "indicatortabel") {
		$tx_indicatortabel{$huidig} = $vertaling;
	} elsif ($veld eq "dimensie") {
		$tx_dimensie{$huidig} = $vertaling;
	}
}

# Get dimensie_ids
$query = "SELECT dimensie_id, waarde
          FROM dimensie";
$ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	my $dimensie_id = $$record{'dimensie_id'};
	my $waarde = $$record{'waarde'};
	$dimensies{$waarde} = $dimensie_id;
}

# Get dimensie elementen ids
$query = "SELECT dim_element_id, dimensie_id, waarde
          FROM dim_element";
$ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	my $dim_element_id = $$record{'dim_element_id'};
	my $dimensie_id = $$record{'dimensie_id'};
	my $waarde = $$record{'waarde'};
	$dim_els{$dimensie_id . $waarde} = $dim_element_id;
}

# Get indicatorfiche_ids
$query = "SELECT indicatorfiche_id, indicator_naam
		  FROM indicatorfiche";
$ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	my $indicatorfiche_id = $$record{'indicatorfiche_id'};
	my $indicator_naam = $$record{'indicator_naam'};
	$fiches{$indicator_naam} = $indicatorfiche_id;
}

my @fields = qw (indicator_fiche_id periode percentage actief verplaatsingsmotief);
my $actief = "J";
my $indicator_fiche_id = $fiches{'verdeling van verplaatsingen volgens verplaatsingsmotief'};
$query = "SELECT d.verplaatsingsmotief, procent, jaartal
          FROM `indicator verdeling verplaatsingen volgens verplaatsingsmotief` i,
		       `dimensie verplaatsingsmotief` d
		  WHERE i.verplaatsingsmotief = d.id";
$ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my $verplaatsingsmotief = $$record{'verplaatsingsmotief'};
	my $periode = $$record{'jaartal'};
	my $percentage = $$record{'procent'};
	$verplaatsingsmotief = $dim_els{$dimensies{'verplaatsing - verplaatsingsmotief'} . $verplaatsingsmotief};
    my (@vals) = map { eval ("\$" . $_ ) } @fields;
	unless (create_record($dbt, "indicator_report", \@fields, \@vals)) {
		$log->fatal("Could not insert record into indicator_report");
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
