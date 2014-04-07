=head1 NAME

indicator2fiche - Map indicatorfiche to indicator information.

=head1 VERSION HISTORY

version 1.0 20 December 2013 DV

=over 4

=item *

Initial release.

=back

=head1 DESCRIPTION

Map information uit Cijferrecords to Indicatorfiche. For now, this is limited to setting the 'Aantal/Percentage' to Percentage (Neen).

=head1 SYNOPSIS

 indicator2fiche.pl

 indicator2fiche -h	Usage
 indicator2fiche -h 1  Usage and description of the options
 indicator2fiche -h 2  All documentation

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
my (%tx_indicatortabel, %tx_dimensie, %tx_aantal_percentage, %tx_meetfrequentie);
my (%fiches, %dimensies, %unk_dims);

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
my @tables = qw (dimensie_fiche);
foreach my $table (@tables) {
	if ($dbt->do("delete from $table")) {
		$log->debug("Contents of table $table deleted");
	} else {
		$log->fatal("Failed to delete `$table'. Error: " . $dbt->errstr);
		exit_application(1);
	}
}

# Collect all translation values
my $query = "SELECT veld, huidig, vertaling
             FROM vertaaltabel
	  	     WHERE veld = 'indicatortabel'
			    OR veld = 'dimensie'
				OR veld = 'aantal_percentage'
				OR veld = 'meetfrequentie'";
my $ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my $huidig = $$record{'huidig'};
	my $vertaling = $$record{'vertaling'};
	my $veld = $$record{'veld'} || "";
	if ($veld eq "indicatortabel") {
		$tx_indicatortabel{$huidig} = $vertaling;
	} elsif ($veld eq "dimensie") {
		$tx_dimensie{$huidig} = $vertaling;
	} elsif ($veld eq "aantal_percentage") {
		$tx_aantal_percentage{$huidig} = $vertaling;
	} elsif ($veld eq "meetfrequentie") {
		$tx_meetfrequentie{$huidig} = $vertaling;
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

# Get indicatorfiche_ids
$query = "SELECT indicatorfiche_id, indicator_naam
		  FROM indicatorfiche";
$ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	my $indicatorfiche_id = $$record{'indicatorfiche_id'};
	my $indicator_naam = $$record{'indicator_naam'};
	$fiches{$indicator_naam} = $indicatorfiche_id;
}

my @fields = qw (dimensie_id fiche_id);
while (my ($huidig, $vertaling) = each %tx_indicatortabel) {
	# Then get dimensies per indicatorfiche
	# But this does not work due to some character conversion issue!
	# review the print select statement, and check how spaces are represented.
	my $fiche_id = $fiches{$vertaling};
	$query = "SELECT * FROM `$huidig` LIMIT 1";
	my $ref = do_select($dbs, $query);
	my $record = @$ref[0];
	foreach my $dimensie (keys $record) {
		if (defined $tx_dimensie{$dimensie}) {
			# Don't handle unknown dimensions
			if ($tx_dimensie{$dimensie} eq 'tbd') {
				next;
			}
			my $dimensie_id = $dimensies{$tx_dimensie{$dimensie}};
			my (@vals) = map { eval ("\$" . $_ ) } @fields;
			unless (create_record($dbt, "dimensie_fiche", \@fields, \@vals)) {
				$log->fatal("Could not insert record into dimensie_fiche");
				exit_application(1);
			}
		} elsif (defined $tx_aantal_percentage{$dimensie}) {
			# For aantal_percentage, check if this is percentage
			# Set aantal_percentage flag to No if so.
			if ($tx_aantal_percentage{$dimensie} eq "procent") {
				my $query = "UPDATE indicatorfiche 
				             SET aantal_percentage = 'N'
							 WHERE indicatorfiche_id = $fiche_id";
				if ($dbt->do($query)) {
					$log->debug("Update aantal percentage for $fiche_id to N.");
				} else {
					$log->fatal("Could not update aantal_percentage in indicatorfiche $fiche_id. Error: " . $dbt->errstr);
					exit_application(1);
				}
			}
		} elsif (defined $tx_meetfrequentie{$dimensie}) {
			# Fine, don't do anything...
			next;
		} else {
			if (($dimensie ne 'tbd') and (not exists $unk_dims{$dimensie})) {
				# $log->error("Onbekende dimensie $dimensie in $huidig");
				print $dimensie."\n";
				$unk_dims{$dimensie} = 1;
			}
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
