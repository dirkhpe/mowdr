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
my @naam_dag = ("maandag", "dinsdag", "woensdag", "donderdag", "vrijdag", "zaterdag", "zondag");
my @naam_maand = ("januari", "februari", "maart", 
	              "april", "mei", "juni",
				  "juli", "augustus", "september",
				  "oktober", "november", "december");

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
use Date::Calc qw(Delta_Days Add_Delta_Days Day_of_Week);

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
my $query = "TRUNCATE TABLE FREQUENTIES";
if ($dbt->do($query)) {
	$log->debug("Frequenties table deleted.");
} else {
	$log->fatal("Could not delete Frequenties Table." . $dbt->errstr);
}


$log->info("Get Frequentie");

my $start_epoch = Delta_Days(1904,1,1,1980,1,1);
my $end_epoch   = Delta_Days(1904,1,1,2030,12,31);

my $curr_epoch = $start_epoch;

my @fields = qw (dagnr datum dag_week dag maand jaar maandnr kwartaal 
                 maand_label kwartaal_label schooljaar_label);
for (my $curr_epoch = $start_epoch; $curr_epoch <= $end_epoch; $curr_epoch++) {
	my $dagnr = $curr_epoch;
	my ($kwartaal, $kwartaal_label, $schooljaar_label);
	my ($jaar, $maandnr, $dag) = Add_Delta_Days(1904,1,1,$curr_epoch);
	my $datum = sprintf("%04D-%02D-%04D", $jaar, $maandnr, $dag);
	if ($maandnr < 4) {
		$kwartaal = "kwartaal 1";
	} elsif ($maandnr < 7) {
		$kwartaal = "kwartaal 2";
	} elsif ($maandnr < 10) {
		$kwartaal = "kwartaal 3";
	} else {
		$kwartaal = "kwartaal 4";
	}
	$kwartaal_label = $jaar . " " . $kwartaal;
	if ($maandnr < 9) {
		$schooljaar_label = ($jaar - 1) . "-" . $jaar;
	} else {
		$schooljaar_label = $jaar . "-" . ($jaar + 1);
	}
	my $maand = $naam_maand[$maandnr - 1];
	my $maand_label = $jaar . " " . $maand;
	my $dag_week = $naam_dag[Day_of_Week($jaar, $maandnr, $dag) - 1];
    my (@vals) = map { eval ("\$" . $_ ) } @fields;
    unless (create_record($dbt, "frequenties", \@fields, \@vals)) {
        $log->fatal("Could not insert record into frequenties");
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
