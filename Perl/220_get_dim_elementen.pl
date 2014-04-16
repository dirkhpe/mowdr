=head1 NAME

get_dim_elementen - Map indicatorfiche to indicator information using dimensie en dim_element from APEX.

=head1 VERSION HISTORY

version 1.1 16 April 2014 DV

=over 4

=item *

Add Microsoft Access Driver Support

=back

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

my ($log, $cfg, $dbs, $dbt, $dba, %dimensies, %a_dims, %dim_el_hash, %map_el_hash, $dim_element_id);

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

# use Carp;
# $SIG{__WARN__} = sub { Carp::confess( @_ ) };

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
$dba = db_connect("cijferdatabank") or exit_application(1);

# Delete tables in sequence from source database
my @tables = qw (map_dim_element);
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

# Get dim_element information
$query = "SELECT * FROM dim_element";
$ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	$dim_el_hash{$$record{dimensie_id} . $$record{waarde}} = $$record{dim_element_id};
}

# Get dim_element_id to add new records
$query = "SELECT max(dim_element_id) dim_max FROM dim_element";
$ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	$dim_element_id = $$record{dim_max}+1;
}

# Get list with Access Dimensie Tables
my $sth = $dba->table_info;	# Review PerlDoc 'DBI' for more information
$ref = $sth->fetchall_arrayref({});
foreach my $record (@$ref) {
	my $table_name = $$record{TABLE_NAME};
	my $searchstring = 'dimensie ';
	if (substr(lc($table_name), 0, length($searchstring)) eq $searchstring) {
		$a_dims{lc($table_name)} = 1;
#		print "Tablename: $table_name\n";
	} else {
#		print "NOT INCLUDED: Tablename : $table_name\n";
	}
}

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
		if (not exists $a_dims{lc($table_name)}) {
			# Table does not exist, try next value
			next;
		}
		# Table does exist so read elementen from the table
		my $query = "SELECT * FROM `$table_name`";
		my $e_ref = do_select($dba, $query);
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
				} # End read columns from row
			# Did I know this value as an element within this dimensie already?
			# From dim_element I know dimensie_id.name_of_the_element
			my $dim_el_record = $dimensies{$f1_dim} . $waarde;
			# I need to know the reverse for map_dim_element: ID_element.name_dimensie
			my $map_el_record = $el_id . $$a_rec{'huidig'};
			if (not(exists $dim_el_hash{$dim_el_record})) {
				$log->error("New dim_element $waarde in dimensie $f1_dim");
				$dim_el_hash{$dim_el_record} = $dim_element_id++;
				my @fields = qw(dim_element_id dimensie_id waarde);
				my @vals = ($dim_el_hash{$dim_el_record}, $dimensies{$f1_dim}, $waarde);
				unless (create_record($dbt, "dim_element", \@fields, \@vals)) {
					$log->fatal("Could not insert record into dim_element");
					exit_application(1);
				}
			} # Add dim_element_id to map_dim_element record:
			$map_el_hash{$map_el_record} = $dim_el_hash{$dim_el_record};
		} # End read elementen from table
	} # End handle this dimensie - so time to write to dim_element for this dimensie
} 

my @el_fields = qw (rec_id acc_element);
while (my ($acc_element, $rec_id) = each %map_el_hash) {
	my (@el_vals) = map { eval ("\$" . $_ ) } @el_fields;
	unless (create_record($dbs, "map_dim_element", \@el_fields, \@el_vals)) {
		$log->fatal("Could not insert record into map_dim_element");
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
