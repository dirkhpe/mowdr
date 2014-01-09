=head1 NAME

indicatormap2txtable - Map indicatorfiche to indicator information.

=head1 VERSION HISTORY

version 1.0 09 January 2014 DV

=over 4

=item *

Initial release.

=back

=head1 DESCRIPTION

Add indicatortable information to tx table.

=head1 SYNOPSIS

 indicatormap2txtable.pl

 indicatormap2txtable -h	Usage
 indicatormap2txtable -h 1  Usage and description of the options
 indicatormap2txtable -h 2  All documentation

=head1 OPTIONS

=over 4

No inline options are available. There is a properties\vo.ini file that contains script settings.

=back

=head1 ADDITIONAL DOCUMENTATION

=cut

###########
# Variables
########### 

my ($log, $cfg, $dbs);

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

# Delete indicatortabel entries from vertaaltabel.
if ($dbs->do("delete from vertaaltabel where veld = 'indicatortabel'")) {
	$log->debug("Contents related to indicatortabel in vertaaltabel deleted");
} else {
	$log->fatal("Failed to delete records from vertaaltabel, Error: " . $dbs->errstr);
	exit_application(1);
}

my @fields = qw (veld huidig vertaling);
my $veld = "indicatortabel";

# Collect all translation values
my $query = "SELECT `Tabelnaam Cijferdatabank`, `indicator Indicatorfiches` 
			 FROM `map_cijferdatabank_indicator`
			 WHERE `Actief` = 'Ja'";
my $ref = do_select($dbs, $query);
foreach my $record (@$ref) {
	my $huidig = $$record{'Tabelnaam Cijferdatabank'};
	my $vertaling = $$record{'indicator Indicatorfiches'};
	my (@vals) = map { eval ("\$" . $_ ) } @fields;
	unless (create_record($dbs, "vertaaltabel", \@fields, \@vals)) {
		$log->fatal("Could not insert record into vertaaltabel");
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
