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

my ($log, $cfg, $dbs, $dbt);
my (%ref_trefwoord, %ref_type_indicator, %ref_meeteenheid, %ref_streefwaardetype, %ref_publicatie);
my (%tx_meetfrequentie, %tx_afdeling, %tx_entiteit);
my (%org, %pers, %fiche2id);

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
		if (exists $ref_trefwoord{$tw}) {
			my $referentie_id = $ref_trefwoord{$tw};
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

sub handle_publ($$) {
	my ($indicatorfiche_id, $publ) = @_;
	my @fields = qw (indicatorfiche_id referentie_id);
	if (exists $ref_publicatie{lc($publ)}) {
		my $referentie_id = $ref_publicatie{lc($publ)};
		my (@vals) = map { eval ("\$" . $_ ) } @fields;
	    unless(create_record($dbt, "gepubliceerd_fiche", \@fields, \@vals)) {
	        $log->fatal("Could not insert record into gepubliceerd_fiche");
	        exit_application(1);
		}
	} else {
		$log->error("Could not find ID for publicatie $publ");
	}
}

sub handle_persoon($$) {
	# Also add 'Dataroom Beheerder'
	my ($indicatorfiche_id, $persoon) = @_;
	my @fields = qw (type indicatorfiche_id persoon_id);
	if (exists $pers{$persoon}) {
		my $persoon_id = $pers{$persoon};
		my $type = "Indicator Beheerder";
		my (@vals) = map { eval ("\$" . $_ ) } @fields;
	    unless(create_record($dbt, "rol", \@fields, \@vals)) {
	        $log->fatal("Could not insert record into rol");
	        exit_application(1);
		}
		$type = "Aanspreekpunt";
		(@vals) = map { eval ("\$" . $_ ) } @fields;
	    unless(create_record($dbt, "rol", \@fields, \@vals)) {
	        $log->fatal("Could not insert record into rol");
	        exit_application(1);
		}
	} else {
		$log->error("Could not find ID for persoon $persoon");
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
	my $veld = $$record{'veld'} || "";
	my $waarde = $$record{'waarde'};
	if ($type eq "Trefwoord") {
		$ref_trefwoord{$waarde} = $referentie_id;
	}
	if ($type eq "Publicatie") {
		$ref_publicatie{lc($waarde)} = $referentie_id;
	}
	if ($veld eq "type_indicator") {
		$ref_type_indicator{$waarde} = $referentie_id;
	}
	if ($veld eq "meeteenheid") {
		$ref_meeteenheid{$waarde} = $referentie_id;
	}
	if ($veld eq "Streefwaardetype") {
		$ref_streefwaardetype{$waarde} = $referentie_id;
	}
}

# Collect all translation values
$query = "SELECT veld, huidig, vertaling
          FROM vertaaltabel";
$ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my $veld = $$record{'veld'};
	my $huidig = $$record{'huidig'};
	my $vertaling = $$record{'vertaling'};
	if (lc($veld) eq "meetfrequentie") {
		$tx_meetfrequentie{lc($huidig)} = $vertaling;
	}
	if (lc($veld) eq "entiteit") {
		$tx_entiteit{lc($huidig)} = $vertaling;
	}
	if (lc($veld) eq "afdeling") {
		$tx_afdeling{lc($huidig)} = $vertaling;
	}
}

# Collect organisatie informatie
$query = "SELECT organisatie_id, entiteit, afdeling
		  FROM organisatie
		  WHERE organisatie_id > 0";
$ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	my $organisatie_id = $$record{organisatie_id};
	my $entiteit = $$record{entiteit} || "";
	my $afdeling = $$record{afdeling} || "";
	$org{"$entiteit $afdeling"} = $organisatie_id;
}

# Collect persoon informatie
$query = "SELECT persoon_id, naam, voornaam
		  FROM persoon
		  WHERE persoon_id > 0";
$ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	my $persoon_id = $$record{persoon_id};
	my $naam = $$record{naam};
	my $voornaam = $$record{voornaam};
	$pers{"$voornaam $naam"} = $persoon_id;
}

# Get indicatorfiche IDs
$query = "SELECT indicatorfiche_id, indicator_naam
		  FROM fiche2id";
$ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	$fiche2id{$$record{indicator_naam}} = $$record{indicatorfiche_id};
}

$log->info("Get Indicatorfiches");
my @fields = qw (indicator_naam definitie doel_meting tijdvenster streefwaarde 
                 bron opmerking meetfrequentie type_indicator meeteenheid
				 aantal_percentage meettechniek streefwaardetype geografische_info
				 vrijgave_metrics aanspreekorganisatie_id sleutel indicatorfiche_id);
# Set default waarden
my $streefwaardetype = $ref_streefwaardetype{"default"};;
$query = "SELECT `Indicator`, `Definitie/Berekeningswijze`, `Doel van de meting`,
                 `Trefwoord1`, `Trefwoord2`, `Trefwoord3`, t.`Type indicator`, `Bron`,
		   	     `Meettechniek(en)`, `Meeteenheid`, `Tijdsvenster`, `Streefwaarde`,
			   	 `Gepubliceerd in (1)`, `Gepubliceerd in (2)`, `Gepubliceerd in (3)`,
				 `Aanspreekpunt`, `Afdeling`, `Entiteit`, `Meetfrequentie`,
				 `Opmerking 1`, `Opmerking 2`, `Opmerking 3` 
             FROM  indicatorfiches i
			 LEFT JOIN `lijst types indicatoren` t ON i.`Type indicator` = t.Id";
$ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my $indicatorfiche_id;
    my $indicator_naam = $$record{'Indicator'};
	if (defined $fiche2id{$indicator_naam}) {
		$indicatorfiche_id = $fiche2id{$indicator_naam};
	} else {
		$log->error("Geen ID gedefinieerd voor Fiche $indicator_naam");
		next;
	}
	my $definitie      = $$record{'Definitie/Berekeningswijze'};
	my $doel_meting    = $$record{'Doel van de meting'};
	my $tijdvenster    = $$record{'Tijdsvenster'};
	my $streefwaarde   = $$record{'Streefwaarde'};
	my $bron           = $$record{'Bron'};
	my $meettechniek   = $$record{'Meettechniek(en)'};
	my $entiteit       = $$record{'Entiteit'} || "VVM De Lijn";
	if (exists $tx_entiteit{lc($entiteit)}) {
		$entiteit      = $tx_entiteit{lc($entiteit)};
	} else {
		$log->error("No translation found for entiteit $entiteit ($indicator_naam)");
		exit_application(1);
	}
	my $afdeling       = $$record{'Afdeling'} || "VVM De Lijn";
	if (exists $tx_afdeling{lc($afdeling)}) {
		$afdeling      = $tx_afdeling{lc($afdeling)};
	} else {
		$log->error("No translation found for afdeling $afdeling ($indicator_naam)");
		exit_application(1);
	}
	my $organisatie    = $entiteit . " " . $afdeling;
	my $aanspreekorganisatie_id = $org{$organisatie};
	my $sleutel        = "$organisatie * $indicator_naam";
	my $aantal_percentage = "J";
	my $geografische_info = "N";
	my $vrijgave_metrics  = "J";
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
	# Meetfrequentie (jaar, maand, kwartaal, schooljaar)
	# must exist in this range.
	my $meetfrequentie = $$record{'Meetfrequentie'} || "";
	if (length($meetfrequentie) == 0) {
		$log->debug("$indicator_naam - Geen meetfrequentie gedefinieerd, gebruik default jaar");
		$meetfrequentie = "jaar";
	}
	if (exists $tx_meetfrequentie{lc($meetfrequentie)}) {
	    $meetfrequentie = $tx_meetfrequentie{lc($meetfrequentie)};
	} else {
		$log->error("$indicator_naam meetfrequentie $meetfrequentie kan niet vertaald worden, skipping indicator");
		next;
	}
	# Type Indicator 
	my $type_indicator = $$record{'Type indicator'};
	if (defined $type_indicator) {
		if (exists($ref_type_indicator{$type_indicator})) {
			$type_indicator = $ref_type_indicator{$type_indicator};
		} else {
			$log->error("$indicator_naam type_indicator $type_indicator niet gevonden in referentie tabel");
			undef $type_indicator;
		}
	}
	# Meeteenheid
	my $meeteenheid = $$record{'Meeteenheid'};
	if (defined $meeteenheid) {
		if (exists($ref_meeteenheid{$meeteenheid})) {
			$meeteenheid = $ref_meeteenheid{$meeteenheid};
		} else {
			$log->error("$indicator_naam meeteenheid $meeteenheid niet gevonden in referentie tabel");
			undef $meeteenheid;
		}
	}
	my (@vals) = map { eval ("\$" . $_ ) } @fields;
	my $new_indicatorfiche_id = create_record($dbt, "indicatorfiche", \@fields, \@vals);
    if (not defined $new_indicatorfiche_id) {
		$log->fatal("Could not insert record into indicatorfiche");
		exit_application(1);
	}
	if (not ($new_indicatorfiche_id == $indicatorfiche_id)) {
		$log->fatal("Indicatorfiche $indicator_naam created with id $new_indicatorfiche_id, expected id $indicatorfiche_id");
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
	# Then handle 'Gepubliceerd in'
	if (defined($$record{'Gepubliceerd in (1)'})) {
		handle_publ($indicatorfiche_id, $$record{'Gepubliceerd in (1)'});
	}
	if (defined($$record{'Gepubliceerd in (2)'})) {
		handle_publ($indicatorfiche_id, $$record{'Gepubliceerd in (2)'});
	}
	if (defined($$record{'Gepubliceerd in (3)'})) {
		handle_publ($indicatorfiche_id, $$record{'Gepubliceerd in (3)'});
	}
	# And handle personen
	my $aanspreekpunt = $$record{'Aanspreekpunt'} || "";
	if (index($aanspreekpunt, "/") > -1) {
		($aanspreekpunt, undef) = split /\//, $aanspreekpunt;
		# I know the second name is Guy Palmans, why bother with the code...
		handle_persoon($indicatorfiche_id, "Guy Palmans");
	}
	if (length($aanspreekpunt) > 0) {
		handle_persoon($indicatorfiche_id, trim($aanspreekpunt));
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
