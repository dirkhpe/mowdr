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

my ($log, $cfg, $dbs, $dbt, $field_val);
my (%tx_indicatortabel, %tx_dimensie, %cols, %tx_aantal_percentage, %tx_meetfrequentie, %tx_dim2column);
my (%freq_jaar, %freq_maand, %freq_schjr, %freq_winter, %freq_kw, %known_errors, %ind_freq);
my (%fiches, %dimensies, %dim_els, @fields, @vals, %meetfrequentie, %map_dim_element);

# Meetfrequentie values
$meetfrequentie{jaar} = 1;
$meetfrequentie{schooljaar} = 1;
$meetfrequentie{maand} = 1;
$meetfrequentie{kwartaal} = 1;

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

sub get_cols($$) {
	my ($indic_table, $indicatorfiche_id) = @_;
	my $valid_rec = "Yes";
	my ($aantal_flag, $frequentie_flag);
	my $query = "SELECT * FROM `$indic_table` LIMIT 1";
	my $ref = do_select($dbs, $query);
	my $record = @$ref[0];
	foreach my $col_name (keys $record) {
		if ($col_name eq 'jaartal') {
			# Every now and then jaartal is used as additional frequentie indicator
			next;
		}
		if (exists $tx_meetfrequentie{$col_name}) {
			if (defined $aantal_flag) {
				$log->error("Duplicate aantal flag in table $indic_table");
				$valid_rec = "No";
			} else {
				$aantal_flag = 1;
			    $cols{$col_name} = $tx_meetfrequentie{$col_name};
			}
		} elsif (exists $tx_aantal_percentage{$col_name}) {
			if (defined $frequentie_flag) {
				$log->error("Duplicate frequentie flag in table $indic_table");
				$valid_rec = "No";
			} else {
				$frequentie_flag = 1;
			    $cols{$col_name} = $tx_aantal_percentage{$col_name};
				if ($cols{$col_name} eq "percentage") {
					# Update Aantal / Percentage flag in indicatorfiche
					my $query = "UPDATE indicatorfiche 
								 SET aantal_percentage = 'N'
								 WHERE indicatorfiche_id = $indicatorfiche_id";
					if ($dbt->do($query)) {
						$log->debug("Aantal percentage flag for $indicatorfiche_id set to N");
					} else {
						$log->fatal("Could not set Aantal percentage flag for $indicatorfiche_id to N. Error: " . $dbt->errstr);
						exit_application(1);
					}
				}
			}
		} elsif (exists $tx_dimensie{$col_name}) {
			if (exists $cols{$col_name}) {
				$log->error("Duplicate dimensie $cols{$col_name} in table $indic_table");
				$valid_rec = "No";
			} else {
			    $cols{$col_name} = $tx_dimensie{$col_name};
			}
		} else {
			$log->error("No translation for dimensie $col_name");
		}
	}
	# Now check for aantal_flag and frequentie_flag
	if (not defined $aantal_flag) {
		$log->error("Aantal / Percentage niet gedefinieerd voor indicator");
	}
	if (not defined $frequentie_flag) {
		$log->error("Frequentie vlag niet gedefinieerd voor indicator");
	}
	return $valid_rec;
}

sub tx_value($$$) {
	my ($field_type, $acc_key, $acc_value) = @_;
	if (($field_type eq 'aantal') or ($field_type eq 'percentage')) {
		# The easy one, aantal / percentage will automatically end up where it belongs.
		return $acc_value;
	}
	# Check if I'm working on meetfrequentie
	if (exists $tx_meetfrequentie{$acc_key}) {
		# Translation exists, so translated value is in $field_type
		# Also not difficult - get the dagnr.
		if ($field_type eq 'jaar') {
			return $freq_jaar{$acc_value};
		} elsif ($field_type eq 'schooljaar') {
			return $freq_schjr{$acc_value};
		} elsif ($field_type eq 'winter') {
			return $freq_winter{$acc_value};
		} elsif ($field_type eq 'maand') {
			return $freq_maand{$acc_value};
		} elsif ($field_type eq 'kwartaal') {
			return $freq_kw{$acc_value};
		} else {
			$log->error("$acc_key translates into meetfrequentie $field_type, but this is unknown meetfrequentie");
			return -1;
		}
	}
	# Not frequentie so now get dim_element number
	my $acc_element = $acc_value . $acc_key;
	if (exists $map_dim_element{$acc_element}) {
		return $map_dim_element{$acc_element};
	} else {
		my $errmsg = "Could not find $acc_element in map_dim_element";
		if (not exists $known_errors{$errmsg}) {
			$known_errors{$errmsg} = 1;
			$log->error("Could not find $acc_element in map_dim_element");
		}
	    return -2;
	}
}

sub get_periode($$) {
	my ($freq, $dagnr) = @_;
	# Get periode parameters
	my $query = "SELECT maand, kwartaal, jaar, maand_label, kwartaal_label, schooljaar_label
				 FROM frequenties
				 WHERE dagnr = $dagnr";
	my $ref = do_select($dbt, $query);
    my $record = @$ref[0];
	if ($freq eq "maand") {
		push @fields, qw(periode label jaar);
		push @vals, $$record{maand_label};
		push @vals, $$record{maand};
		push @vals, $$record{jaar};
	} elsif ($freq eq "kwartaal") {
		push @fields, qw(periode label jaar);
		push @vals, $$record{kwartaal_label};
		push @vals, $$record{kwartaal};
		push @vals, $$record{jaar};
	} elsif ($freq eq "schooljaar") {
		push @fields, qw(periode schooljaar);
		push @vals, $$record{schooljaar_label};
		push @vals, $$record{schooljaar_label};
	} elsif ($freq eq "jaar") {
		push @fields, qw(periode jaar);
		push @vals, $$record{jaar};
		push @vals, $$record{jaar};
	} else {
		$log->error("Unknown meetfrequentie $freq");
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
my @tables = qw (indicator_report);
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
	  	     WHERE (veld = 'indicatortabel'
			    OR  veld = 'dimensie'
				OR  veld = 'aantal_percentage'
				OR  veld = 'meetfrequentie'
				OR  veld = 'dim2column')
				AND (NOT(huidig = 'tbd'))
				AND (NOT(vertaling = 'tbd'))";
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
	} elsif ($veld eq "dim2column") {
		$tx_dim2column{$huidig} = $vertaling;
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
$query = "SELECT indicatorfiche_id, indicator_naam, meetfrequentie
		  FROM indicatorfiche";
$ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	my $indicatorfiche_id = $$record{'indicatorfiche_id'};
	my $indicator_naam = $$record{'indicator_naam'};
	$fiches{$indicator_naam} = $indicatorfiche_id;
	$ind_freq{$indicatorfiche_id} = $$record{'meetfrequentie'};	# Remember Meetfrequenties
}

# Get frequentie jaarlijks
$query = "SELECT a.Id, (select min(dagnr) from mow_fase1.frequenties where jaar = a.jaar) dagnr
          FROM `frequentie jaarlijks` a";
$ref = do_select($dbs, $query);
foreach my $record(@$ref) {
	$freq_jaar{$$record{Id}} = $$record{dagnr};
}

# Get frequentie maandelijks
$query = "SELECT a.Id, (select min(dagnr) from mow_fase1.frequenties
                        where jaar = substr(a.maand,1,4) 
					      and maandnr = substr(a.maand,6,2))	dagnr
          FROM `frequentie maandelijks` a";
$ref = do_select($dbs, $query);
foreach my $record(@$ref) {
	$freq_maand{$$record{Id}} = $$record{dagnr};
}

# Get frequentie schooljaar (winter heeft zelfde start, meer entries dan schooljaar)
$query = "SELECT a.Id, (select min(dagnr) from mow_fase1.frequenties
                        where schooljaar_label = a.schooljaar)	dagnr
          FROM `frequentie per schooljaar` a";
$ref = do_select($dbs, $query);
foreach my $record(@$ref) {
	$freq_schjr{$$record{Id}} = $$record{dagnr};
}

# Get frequentie winter
$query = "SELECT a.Id, (select min(dagnr) from mow_fase1.frequenties
                        where schooljaar_label = a.winter)	dagnr
          FROM `frequentie per winter` a";
$ref = do_select($dbs, $query);
foreach my $record(@$ref) {
	$freq_winter{$$record{Id}} = $$record{dagnr};
}

# Get frequentie kwartaal 
$query = "SELECT a.Id, (select min(dagnr) from mow_fase1.frequenties
                        where jaar = substr(a.kwartaal,1,4) 
					      and kwartaal = concat('kwartaal ', substr(a.kwartaal,8,1))) dagnr
          FROM `frequentie per kwartaal` a";
$ref = do_select($dbs, $query);
foreach my $record(@$ref) {
	$freq_kw{$$record{Id}} = $$record{dagnr};
}

# Get Dimensie Element Mapping from Access to Fase1
$query = "SELECT rec_id, acc_element
		  FROM map_dim_element";
$ref = do_select($dbs, $query);
foreach my $record(@$ref) {
	$map_dim_element{$$record{acc_element}} = $$record{rec_id};
}

my $actief = "J";
$query = "SELECT a.Id, (select min(dagnr) from mow_fase1.frequenties where jaar = a.jaar) dagnr
          FROM `frequentie jaarlijks` a";
$ref = do_select($dbs, $query);
foreach my $record(@$ref) {
	$freq_jaar{$$record{Id}} = $$record{dagnr};
}

while (my ($acc_ind, $f1_ind) = each %tx_indicatortabel) {
	$log->info("Investigating $acc_ind");
	undef %cols;
	if (not(get_cols($acc_ind, $fiches{$f1_ind}) eq "Yes")) {
		$log->error("Skip $acc_ind");
		next;
	}
	my $query = "SELECT * FROM `$acc_ind`";
	my $ref = do_select($dbs, $query);
	foreach my $record (@$ref) {
		undef @fields;
		undef @vals;
		my $indicatorfiche_id = $fiches{$f1_ind};
		push @fields, 'indicatorfiche_id';
		push @vals, $indicatorfiche_id;
		while (my ($key, $value) = each %$record) {
			# Value must be positive integer, pointing to a reference table.
			# In a few cases (stormvloedpeil) no value has been selected, value 0 is in value column.
			if (exists $cols{$key}) {
				# Translate values aantal, meetfrequentie, dimensie
				if (exists $tx_meetfrequentie{$cols{$key}}) {
					$field_val = "dagnr";
					my $dagnr  = tx_value($cols{$key}, $key, $value);
					get_periode($ind_freq{$indicatorfiche_id}, $dagnr);
 				} elsif (($cols{$key} eq "aantal") or ($cols{$key} eq "percentage")) {
					$field_val = $cols{$key};
				} else {
					$field_val = $tx_dim2column{$cols{$key}};
				}
				push @fields, $field_val;
				push @vals, tx_value($cols{$key}, $key, $value);
			}
		}
		push @fields, 'actief';
		push @vals, 'J';
		unless (create_record($dbt, "indicator_report", \@fields, \@vals)) {
			$log->fatal("Could not insert record into indicator_report");
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
