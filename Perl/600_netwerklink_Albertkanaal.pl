=head1 NAME

netwerklink_Albertkanaal - Special handling for Netwerklink Albertkanaal fiches.

=head1 VERSION HISTORY

version 1.0 13 March 2014 DV

=over 4

=item *

Initial release.

=back

=head1 DESCRIPTION

This procedure will add dimensie netwerklink to indicatorfiches 72 and 74 for Albertkanaal.

=head1 SYNOPSIS

 netwerklink_Albertkanaal.pl

 netwerklink_Albertkanaal -h	Usage
 netwerklink_Albertkanaal -h 1  Usage and description of the options
 netwerklink_Albertkanaal -h 2  All documentation

=head1 OPTIONS

=over 4

No inline options are available. There is a properties\vo.ini file that contains script settings.

=back

=head1 ADDITIONAL DOCUMENTATION

=cut

###########
# Variables
########### 

my ($log, $cfg, $dbt, $dim_element_id);
my $dimensie_id = 42;	# ID for netwerklink

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

# Check dim_element 'Albertkanaal' in dimensie 'Netwerklink'.
my $query = "SELECT dim_element_id
             FROM dim_element
			 WHERE dimensie_id = $dimensie_id 
			   AND waarde = 'Albertkanaal'";
my $ref = do_select($dbt, $query);
my $nr_recs = @$ref;
if ($nr_recs > 1) {
	$log->fatal("Multiple records Netwerklink - Albertkanaal found, exiting...");
	exit_application(1);
} elsif ($nr_recs == 1) {
	my $record = @$ref[0];
	$dim_element_id = $$record{dim_element_id};
	$log->info("Netwerklink - Albertkanaal exists already, id: $dim_element_id");
} else {
	my @fields = qw(dimensie_id waarde);
	my @vals   = qw(42 Albertkanaal);
	$dim_element_id = create_record($dbt, "dim_element", \@fields, \@vals);
    if (defined $dim_element_id) {
		$log->info("Netwerklink - Albertkanaal added as id $dim_element_id");
	} else {
		$log->fatal("Could not insert record into indicator_report");
		exit_application(1);
	}
}

# Update Indicator_report with this element_id
$query = "UPDATE indicator_report 
          SET netwerklink = $dim_element_id
		  WHERE (indicatorfiche_id = 72)
		     OR (indicatorfiche_id = 74)";
if ($dbt->do($query)) {
	$log->info("Indicator_Report updated for IDs 72 and 74");
} else {
	$log->fatal("Failed to update Indicator_Report. Error: " . $dbt->errstr);
	exit_application(1);
}

# Verify indicatorfiche - dimensie is defined
# Delete records if they were defined already 
# And add them again
$query = "DELETE FROM dimensie_fiche
		  WHERE dimensie_id = $dimensie_id 
		    AND ((fiche_id = 72) OR 
			     (fiche_id = 74))";
if ($dbt->do($query)) {
	$log->debug("Delete from dimensie_fiche for IDs 72 and 74 done");
} else {
	$log->fatal("Delete from dimensie_fiche failed. Error: " . $dbt->errstr);
	exit_application(1);
}
# Now add the records
my @fields = qw(dimensie_id fiche_id);
my @fiches = (72, 74);
foreach my $fiche_id (@fiches) {
	my (@vals) = map { eval ("\$" . $_ ) } @fields;
	unless (create_record($dbt, "dimensie_fiche", \@fields, \@vals)) {
		$log->fatal("Could not insert record into dimensie_fiche. Error: " . $dbt->errstr);
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
