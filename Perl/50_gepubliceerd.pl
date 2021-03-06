=head1 NAME

Gepubliceerd - Extract gepubliceerd values from the Indicatorfiches.

=head1 VERSION HISTORY

version 1.0 19 December 2013 DV

=over 4

=item *

Initial release.

=back

=head1 DESCRIPTION

Extract the gepubliceerd values from the mow_access indicatorfiche tabel.

=head1 SYNOPSIS

 gepubliceerd.pl

 gepubliceerd -h	Usage
 gepubliceerd -h 1  Usage and description of the options
 gepubliceerd -h 2  All documentation

=head1 OPTIONS

=over 4

No inline options are available. There is a properties\vo.ini file that contains script settings.

=back

=head1 ADDITIONAL DOCUMENTATION

=cut

###########
# Variables
########### 

my ($log, $cfg, $dbs, $dbt, %gepubliceerd_hash);

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

sub handle_trefwoord($) {
	
	my ($trefwoord) = @_;
	
    # Initialize Referentie velden
    my $type = "Publicatie";
    my $actief = "J";
    my @fields = qw (type waarde actief);

	if (not (exists $gepubliceerd_hash{lc($trefwoord)})) {
		$gepubliceerd_hash{lc($trefwoord)} = 1;
		my $waarde = $trefwoord;
	    my (@vals) = map { eval ("\$" . $_ ) } @fields;
	    unless (create_record($dbt, "referentie", \@fields, \@vals)) {
		    $log->fatal("Could not insert record into referentie");
		    exit_application(1);
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

# Delete existing gepubliceerd from referentie tabel
my $query = "DELETE FROM referentie WHERE type = 'Publicatie'";
if ($dbt->do($query)) {
	$log->debug("Gepubliceerd deleted from referentie tabel");
} else {
	$log->fatal("Could not delete gepubliceerd from referentie tabel" . $dbt->errstr);
}


$log->info("Get Gepubliceerd");
$query = "SELECT distinct `Gepubliceerd in (1)`,  
                          `Gepubliceerd in (2)`,
						  `Gepubliceerd in (3)` 
             FROM indicatorfiches";
my $ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my $publ1 = $$record{'Gepubliceerd in (1)'};
	my $publ2 = $$record{'Gepubliceerd in (2)'};
	my $publ3 = $$record{'Gepubliceerd in (3)'};
	if (defined $publ1) {
		handle_trefwoord($publ1);
	}
	if (defined $publ2) {
		handle_trefwoord($publ2);
	}
	if (defined $publ3) {
		handle_trefwoord($publ3);
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
