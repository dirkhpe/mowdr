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
my (%tx_indicatortabel, %tx_dimensie, %cols, %tx_aantal_percentage, %tx_meetfrequentie);
my (%freq_jaar, %freq_maand, %freq_schjr, %freq_kw);
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

sub get_cols($) {
	my ($indic_table) = @_;
	my $valid_rec = "Yes";
	my ($aantal_flag, $frequentie_flag);
	my $query = "SELECT * FROM `$indic_table` LIMIT 1";
	my $ref = do_select($dbs, $query);
	my $record = @$ref[0];
	foreach my $col_name (keys $record) {
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
			}
		} elsif (exists $tx_dimensie{$col_name}) {
			if (exists $cols{$col_name}) {
				$log->error("Duplicate dimensie $cols{$col_name} in table $indic_table");
				$valid_rec = "No";
			} else {
			    $cols{$col_name} = $tx_dimensie{$col_name};
			}
		}
	}
	return $valid_rec;
}

sub tx_value($$$) {
	my ($field_type, $acc_key, $acc_value) = @_;
	if (($field_type eq 'aantal') or ($field_type eq 'procent')) {
		# The easy one, aantal / procent will automatically end up where it belongs.
		return $acc_value;
	}
	if ($field_type eq 'meetfrequentie') {
		# Also not difficult - get the dagnr.
		if ($acc_value eq 'jaar') {
			return $freq_jaar{$acc_key};
		} elsif ($acc_value eq 'schooljaar') {
			return $freq_schjr{$acc_key};
		} elsif ($acc_value eq 'maand') {
			return $freq_maand{$acc_key};
		} elsif ($acc_value eq 'kwartaal') {
			return $freq_kw{$acc_key};
		}
	}
	# Now get dim_element number
	my $acc_element = $acc_value . $acc_key;
	if (exists $map_dim_element{$acc_element}) {
		return $map_dim_element{$acc_element};
	} else {
		$log->error("Could not find $acc_element in map_dim_element");
	    return -2;
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
				OR  veld = 'meetfrequentie')
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
                        where schooljaar_label = a.winter)	dagnr
          FROM `frequentie per winter` a";
$ref = do_select($dbs, $query);
foreach my $record(@$ref) {
	$freq_schjr{$$record{Id}} = $$record{dagnr};
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
	undef %cols;
	if (not(get_cols($acc_ind) eq "Yes")) {
		$log->error("Skip $acc_ind");
		next;
	}
	my $query = "SELECT * FROM `$acc_ind`";
	my $ref = do_select($dbs, $query);
	foreach my $record (@$ref) {
		undef @fields;
		undef @vals;
		push @fields, 'indicatorfiche_id';
		push @vals, $fiches{$f1_ind};
		while (my ($key, $value) = each %$record) {
			if (exists $cols{$key}) {
				# Translate values aantal, meetfrequentie, dimensie
				if (exists $meetfrequentie{$cols{$key}}) {
					$field_val = "dagnr";
				} else {
					$field_val = $cols{$key};
				}			
				push @fields, $field_val;
				push @vals, tx_value($cols{$key}, $key, $value);
			}
		}
		# unless (create_record($dbt, "indicator_report", \@fields, \@vals)) {
		#	$log->fatal("Could not insert record into indicator_report");
		#	exit_application(1);
		#}
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
