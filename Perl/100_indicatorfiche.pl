=head1 NAME

indicatorfiche - Extract the Indicatorfiche records.

=head1 VERSION HISTORY

version 1.0 19 December 2013 DV

=over 4

=item *

Initial release.

=back

=head1 DESCRIPTION

Extract the reference values from the mow_access indicatorfiche tabel.

=head1 SYNOPSIS

 indicatorfiche.pl

 indicatorfiche -h	Usage
 indicatorfiche -h 1  Usage and description of the options
 indicatorfiche -h 2  All documentation

=head1 OPTIONS

=over 4

No inline options are available. There is a properties\vo.ini file that contains script settings.

=back

=head1 ADDITIONAL DOCUMENTATION

=cut

###########
# Variables
########### 

my ($log, $cfg, $dbs, $dbt, %trefwoorden);

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

sub handle_tw($$) {
	my ($indicatorfiche_id, $tw_str) = @_;
	my @fields = qw (indicatorfiche_id referentie_id);
	my @tw_arr = split /\|/, $tw_str;
	foreach my $tw (@tw_arr) {
		if (exists $trefwoorden{$tw}) {
			my $referentie_id = $trefwoorden{$tw};
			my (@vals) = map { eval ("\$" . $_ ) } @fields;
	        unless(create_record($dbt, "trefwoord_fiche", \@fields, \@vals)) {
		        $log->fatal("Could not insert record into trefwoord_fiche");
		        exit_application(1);
			}
		} else {
			$log->error("Could not find ID for trefwoord $tw");
		}
	}
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
my @tables = qw (trefwoord_fiche indicatorfiche);
foreach my $table (@tables) {
	if ($dbt->do("delete from $table")) {
		$log->debug("Contents of table $table deleted");
	} else {
		$log->fatal("Failed to delete `$table'. Error: " . $dbt->errstr);
		exit_application(1);
	}
}

# Collect all reference values
my $query = "SELECT referentie_id, type, tabel, veld, waarde
             FROM referentie";
my $ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	my $referentie_id = $$record{'referentie_id'};
	my $type = $$record{'type'};
	my $waarde = $$record{'waarde'};
	if ($type eq "Trefwoord") {
		$trefwoorden{$waarde} = $referentie_id;
	}
}

my @fields = qw (indicator_naam definitie doel_meting tijdvenster streefwaarde bron opmerking);
$log->info("Get Indicatorfiches");
$query = "SELECT `Indicator`, `Definitie/Berekeningswijze`, `Doel van de meting`,
                 `Trefwoord1`, `Trefwoord2`, `Trefwoord3`, t.`Type indicator`, `Bron`,
		   	     `Meettechniek(en)`, `Meeteenheid`, `Tijdsvenster`, `Streefwaarde`,
			   	 `Gepubliceerd in (1)`, `Gepubliceerd in (2)`, `Gepubliceerd in (3)`,
				 `Aanspreekpunt`, `Afdeling`, `Entiteit`,
				 `Opmerking 1`, `Opmerking 2`, `Opmerking 3` 
             FROM  indicatorfiches i
			 LEFT JOIN `lijst types indicatoren` t ON i.`Type indicator` = t.Id";
$ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my $indicatorfiche_id;
    my $indicator_naam = $$record{'Indicator'};
	my $definitie      = $$record{'Definitie/Berekeningswijze'};
	my $doel_meting    = $$record{'Doel van de meting'};
	my $tijdvenster    = $$record{'Tijdsvenster'};
	my $streefwaarde   = $$record{'Streefwaarde'};
	my $bron           = $$record{'Bron'};
	my $opmerking      = "";
	if (defined($$record{'Opmerking 1'})) {
		$opmerking    .= $$record{'Opmerking 1'};
	}
	if (defined($$record{'Opmerking 2'})) {
		$opmerking    .= $$record{'Opmerking 2'};
	}
	if (defined($$record{'Opmerking 3'})) {
		$opmerking    .= $$record{'Opmerking 3'};
	}
	my $trefwoorden    = "";
	my (@vals) = map { eval ("\$" . $_ ) } @fields;
	$indicatorfiche_id = create_record($dbt, "indicatorfiche", \@fields, \@vals);
    if (not defined $indicatorfiche_id) {
		$log->fatal("Could not insert record into indicatorfiche");
		exit_application(1);
	}
	# Indicatorfiche ID known, now link to the other attributes
	# First get Trefwoorden
	my @tw_arr;
	if (defined($$record{'Trefwoord1'})) {
		push @tw_arr, $$record{'Trefwoord1'};
	}	
	if (defined($$record{'Trefwoord2'})) {
		push @tw_arr, $$record{'Trefwoord2'};
	}	
	if (defined($$record{'Trefwoord3'})) {
		push @tw_arr, $$record{'Trefwoord3'};
	}
	my $nr_tw = @tw_arr;
	if ($nr_tw > 0) {
	    handle_tw($indicatorfiche_id, join("|", @tw_arr));
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
