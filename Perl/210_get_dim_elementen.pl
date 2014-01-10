=head1 NAME

get_dim_elementen - Map indicatorfiche to indicator information.

=head1 VERSION HISTORY

version 1.0 20 December 2013 DV

=over 4

=item *

Initial release.

=back

=head1 DESCRIPTION

Collect the dimensie elementen.

=head1 SYNOPSIS

 get_dim_elementen.pl

 get_dim_elementen -h	Usage
 get_dim_elementen -h 1  Usage and description of the options
 get_dim_elementen -h 2  All documentation

=head1 OPTIONS

=over 4

No inline options are available. There is a properties\vo.ini file that contains script settings.

=back

=head1 ADDITIONAL DOCUMENTATION

=cut

###########
# Variables
########### 

my ($log, $cfg, $dbs, $dbt, %dimensies, %a_dims, %dim_el, %el_arr);

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

# Delete tables in sequence from target database
my @tables = qw (dim_element);
foreach my $table (@tables) {
	if ($dbt->do("delete from $table")) {
		$log->debug("Contents of table $table deleted");
	} else {
		$log->fatal("Failed to delete `$table'. Error: " . $dbt->errstr);
		exit_application(1);
	}
}

# Delete tables in sequence from source database
@tables = qw (map_dim_element);
foreach my $table (@tables) {
	if ($dbs->do("delete from $table")) {
		$log->debug("Contents of table $table deleted");
	} else {
		$log->fatal("Failed to delete `$table'. Error: " . $dbs->errstr);
		exit_application(1);
	}
}

# Get dimensie_ids
my $query = "SELECT dimensie_id, waarde
          FROM dimensie";
my $ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	my $dimensie_id = $$record{'dimensie_id'};
	my $waarde = $$record{'waarde'};
	$dimensies{$waarde} = $dimensie_id;
}

# Get list with Access Dimensie Tables
$query = "SELECT distinct table_name
          FROM access_repository
		  WHERE table_name like 'dimensie %'";
$ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my $table_name = $$record{'table_name'};
	$a_dims{$table_name} = 1;
}

my @fields = qw (dimensie_id waarde);

# Collect all F1 Dimensies for which an Access dimensie exists
$query = "SELECT distinct vertaling
             FROM vertaaltabel
	  	     WHERE veld = 'dimensie'
			   AND (NOT (huidig = 'tbd'))
			   AND (NOT (vertaling = 'tbd'))";
$ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my $f1_dim = $$record{'vertaling'};
	# Collect Access Dimensie tabellen that need to be consolidated into this F1 Dimensie
	my $query = "SELECT distinct huidig
	             FROM vertaaltabel
				 WHERE veld = 'dimensie'
				   AND vertaling = '$f1_dim'";
	my $a_ref = do_select($dbs, $query);
	foreach my $a_rec (@$a_ref) {
		# Check if table exists
		my $table_name = "dimensie $$a_rec{'huidig'}";
		if (not exists $a_dims{$table_name}) {
			# Table does not exist, try next value
			next;
		}
		# Table does exist so read elementen from the table
		my $query = "SELECT * FROM `$table_name`";
		my $e_ref = do_select($dbs, $query);
		foreach my $e_rec (@$e_ref) {
			# Now extract value from access dimensie table
			my ($el_id, $waarde);
			foreach my $dim_key (keys $e_rec) {
				# Remember the ID for translation from the indicatorfiche records
				if (lc($dim_key) eq 'id') {
					$el_id = $$e_rec{$dim_key};
					next;
				}
				# Ignore provincie field for table hoofdgemeente
				if ((lc($dim_key) eq 'provincie') and ($table_name eq 'dimensie hoofdgemeente')) {
					next;
				}
				# Now go for the value!
				$waarde = $$e_rec{$dim_key};
				# Assign waarde to dimensie using hash to avoid duplicates
				$dim_el{$waarde} = $dimensies{$f1_dim};
			} 
			# End read columns from row
			# Remember ID.Dimensie to Waarde, to use during Cijferrecord mapping
			push (@{$el_arr{$waarde}}, $el_id . $$a_rec{'huidig'});
		} # End read elementen from table
	} # End handle this dimensie - so time to write to dim_element for this dimensie
	while (my ($waarde, $dimensie_id) = each %dim_el) {
		my (@vals) = map { eval ("\$" . $_ ) } @fields;
		my $rec_id = create_record($dbt, "dim_element", \@fields, \@vals);
        if (defined $rec_id) {
			my @el_fields = qw (rec_id acc_element);
			# Now read all dimensie elementen from $el_arr{$waarde}
			foreach my $acc_element (@{$el_arr{$waarde}}) {
				my (@el_vals) = map { eval ("\$" . $_ ) } @el_fields;
				unless (create_record($dbs, "map_dim_element", \@el_fields, \@el_vals)) {
					$log->fatal("Could not insert record into map_dim_element");
					exit_application(1);
				}
			}
		} else {
		    $log->fatal("Could not insert record into dim_element");
		    exit_application(1);
		}
	} 
    # End writing to dim_element
	# Clear dim_element to be ready for the next round
	undef %dim_el;
	undef %el_arr;
} 

exit_application(0);

=head1 To Do

=over 4

=item *

Nothing for now...

=back

=head1 AUTHOR

Any suggestions or bug reports, please contact E<lt>dirk.vermeylen@hp.comE<gt>
