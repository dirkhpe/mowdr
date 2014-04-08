=head1 NAME

handle_beleidsdocumenten - Map indicatorfiche to indicator information.

=head1 VERSION HISTORY

version 1.0 20 December 2013 DV

=over 4

=item *

Initial release.

=back

=head1 DESCRIPTION

Load the Beleidsdocumenten table.

=head1 SYNOPSIS

 handle_beleidsdocumenten.pl

 handle_beleidsdocumenten -h	Usage
 handle_beleidsdocumenten -h 1  Usage and description of the options
 handle_beleidsdocumenten -h 2  All documentation

=head1 OPTIONS

=over 4

No inline options are available. There is a properties\vo.ini file that contains script settings.

=back

=head1 ADDITIONAL DOCUMENTATION

=cut

###########
# Variables
########### 

my ($log, $cfg, $dbs, $dbt, %fiche2id, @title_id, @toc_cnt, $doc_id);
my $lvl = 0;
my $prev_lvl = 0;
my $beleidsdocument_id = 0;

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

sub handle_rec($$$) {
	my ($lvl, $titel, $toc) = @_;
	my @fields = qw (beleidsdocument_id titel parent_id toc doc_id);
	$beleidsdocument_id++;
	if ($lvl == ($prev_lvl + 1)) {
		my $parent_id = $title_id[$prev_lvl];
		my (@vals) = map { eval ("\$" . $_ ) } @fields;
		$title_id[$lvl] = create_record($dbt, "beleidsdocument", \@fields, \@vals);
		$prev_lvl = $lvl;
	} elsif ($lvl <= $prev_lvl) {
		if ($lvl > 0) {
			my $parent_id = $title_id[$lvl - 1];
			my (@vals) = map { eval ("\$" . $_ ) } @fields;
			$title_id[$lvl] = create_record($dbt, "beleidsdocument", \@fields, \@vals);
			$prev_lvl = $lvl;
		} else {
			my $parent_id = -1;
			$doc_id++;
			my (@vals) = map { eval ("\$" . $_ ) } @fields;
			$title_id[$lvl] = create_record($dbt, "beleidsdocument", \@fields, \@vals);
			$prev_lvl = 0;
		}
	} else {
		$log->fatal("Unexpected Jump from level $prev_lvl to $lvl at title $titel, exiting...");
		exit_application(1);
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

# Remove Parent_IDs from beleidsdocumenten.
# This is required to allow delete.
my $query = "UPDATE beleidsdocument SET parent_id = NULL";
$dbt->do($query);

# Delete tables in sequence from target database
my @tables = qw (beleidsdocument document_fiche);
foreach my $table (@tables) {
	if ($dbt->do("delete from $table")) {
		$log->debug("Contents of table $table deleted");
	} else {
		$log->fatal("Failed to delete `$table'. Error: " . $dbt->errstr);
		exit_application(1);
	}
}

# Get indicatorfiche_ids
$query = "SELECT indicatorfiche_id, indicator_naam
          FROM fiche2id";
my $ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	$fiche2id{$$record{indicator_naam}} = $$record{indicatorfiche_id};
}

# Insert empty record into Beleidsdocument
my @fields = qw (beleidsdocument_id titel parent_id);
my @vals = (-1, "(geen document)", -1);
unless (create_record($dbt, "beleidsdocument", \@fields, \@vals)) {
	$log->fatal("Could not insert record into beleidsdocument");
    exit_application(1);
}

handle_rec(0, "Beleidsnota 2009-2014", 0);

# Get Beleidsdocumenten
$query = "SELECT titel, toc
          FROM beleidsdocument
		  ORDER BY toc";
$ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my $titel = $$record{titel} || "";
	my $toc   = $$record{toc}   || "";
	$lvl = int ((length($toc) + 1) / 2);
	handle_rec($lvl, $titel, $toc);
}

exit_application(0);

=head1 To Do

=over 4

=item *

Nothing for now...

=back

=head1 AUTHOR

Any suggestions or bug reports, please contact E<lt>dirk.vermeylen@hp.comE<gt>
