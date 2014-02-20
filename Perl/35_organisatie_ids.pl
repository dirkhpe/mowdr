=head1 NAME

Get organisatie names into organisatie IDs.

=head1 VERSION HISTORY

version 1.0 05 February 2014 DV

=over 4

=item *

Initial release.

=back

=head1 DESCRIPTION

This script gets the attribute names of the organisation and converts them into attribute IDs. Then the temporary table organisatie_temp is deleted.

=head1 SYNOPSIS

 organisatie_ids.pl

 organisatie_ids -h	Usage
 organisatie_ids -h 1  Usage and description of the options
 organisatie_ids -h 2  All documentation

=head1 OPTIONS

=over 4

No inline options are available. There is a properties\vo.ini file that contains script settings.

=back

=head1 ADDITIONAL DOCUMENTATION

=cut

###########
# Variables
########### 

my ($log, $cfg, $dbs, $dbt, %refid);

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
$dbt = db_connect("mow_fase1")  or exit_application(1);

# Delete organisatie table except record -1
if ($dbt->do("delete from organisatie where organisatie_id > -1")) {
	$log->debug("Contents of table organisatie deleted");
} else {
	$log->fatal("Failed to delete organisatie. Error: " . $dbt->errstr);
 	exit_application(1);
}

# Get IDs from referentie tabel.
my $query = "SELECT referentie_id, waarde
			 FROM referentie
			 where tabel = 'Organisatie'";
my $ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	$refid{$$record{waarde}} = $$record{referentie_id};
}

my @fields = qw (beleidsdomein entiteit afdeling);
# Then get all organisatie records
$query = "SELECT beleidsdomein, entiteit, afdeling
          FROM organisatie_temp
		  WHERE organisatie_id > -1";
$ref = do_select($dbt, $query);
foreach my $record (@$ref) {
	my $beleidsdomein = $refid{$$record{beleidsdomein}};
	my $entiteit      = $refid{$$record{entiteit}};
	my $afdeling      = $refid{$$record{afdeling}};
	my (@vals) = map { eval ("\$" . $_ ) } @fields;
	unless (create_record($dbt, "organisatie", \@fields, \@vals)) {
		$log->fatal("Could not insert record into organisatie");
		exit_application(1);
	}
}

# Drop table organisatie_temp
$query = "DROP TABLE organisatie_temp";
if ($dbt->do($query)) {
	$log->debug("Table organisatie_temp dropped");
} else {
	$log->fatal("Failed to drop table organisatie_temp. Error: " . $dbt->errstr);
	exit_application(1);
}

exit_application(0);

=head1 To Do

=over 4

=item *

Nothing for now...

=back

=head1 AUTHOR

Any suggestions or bug reports, please contact E<lt>dirk.vermeylen@hp.comE<gt>
