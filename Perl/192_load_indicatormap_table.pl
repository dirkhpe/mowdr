=head1 NAME

load_indicatormap_table - This script will load the indicator map table from excel.

=head1 VERSION HISTORY

version 1.0 09 January 2014 DV

=over 4

Initial release.

=back

=head1 DESCRIPTION

This script will load the indicator map table the mow_access database.

=head1 SYNOPSIS

 load_indicatormap_table.pl [-x data_mapping.xls file]

 load_indicatormap_table -h	Usage
 load_indicatormap_table -h 1  Usage and description of the options
 load_indicatormap_table -h 2  All documentation

=head1 OPTIONS

=over 4

=item B<-x Full path to data_mapping file in .xls format>

Full path and file to the data_mapping report that contains tabe vertaaltabel. The report needs to be in .xls format, since the Perl application cannot handle .xlsx files.

=back

=head1 ADDITIONAL DOCUMENTATION

=cut

###########
# Variables
########### 

my ($log, $dbh, $xls_file);
my $table = "map_cijferdatabank_indicator";

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
use DbUtil qw (db_connect);

use Spreadsheet::ParseExcel;
use Spreadsheet::ParseExcel::Fmt8Bit;
use XlsUtil qw(small_cell_handler import_sheet);

use Data::Dumper;

use IniUtil qw (load_ini get_ini);
use Log::Log4perl qw (get_logger);
use SimpleLog qw (setup_logging);

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
	if (defined $dbh) {
		$dbh->disconnect;
	}
	$log->info("Exit application with return code $return_code.\n");
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
getopts("h:x:", \%options) or pod2usage(-verbose => 0);
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
my $cfg = load_ini($ini);
# Start logging
setup_logging;
$log = get_logger();
$log->info("Start application");
# Get xls file
if (defined $options{"x"}) {
	$xls_file = $options{"x"};
	if (not(-r $xls_file)) {
		$log->fatal("Cannot read excel file $xls_file.");
		exit_application(1);
	}
} else {
	$log->fatal("Excel file not defined, exiting...");
	exit_application(1);
}

# Show input parameters
if ($log->is_debug()) {
	while (my($key, $value) = each %options) {
		$log->debug("$key: $value");
	}
}
# End handle input values

# Make database connection for vo database
$dbh = db_connect('mow_access') or exit_application(1);

# Truncate table
if ($dbh->do("truncate $table")) {
	$log->debug("Table $table truncated");
} else {
	$log->fatal("Failed to truncate `$table'. Error: " . $dbh->errstr);
	exit_application(1);
}

# Open Excel object, define cell handler for memory savings
$log->info("Launch excel");
my $InExcel = Spreadsheet::ParseExcel->new(CellHandler => \&small_cell_handler, 
NotSetCell => 1);
if (not(defined $InExcel)) {
	$log->fatal("Can't launch Excel, exiting...");
	exit_application(1);
}

# Launch the Excel Formatter
$log->info("Launch excel formatter");
my $oFmt = new Spreadsheet::ParseExcel::Fmt8Bit;
if (not(defined $oFmt)) {
	$log->fatal("Can't launch Excel Formatter, exiting...");
	exit_application(1);
}

$log->info("Parse file into workbook object");
my $workbook = $InExcel->parse($xls_file);
if (not(defined $workbook)) {
	$log->fatal("Can't parse excel file $xls_file: " . $InExcel->error());
	exit_application(1);
}

# Get the worksheets in the workbook
$log->info("Get the worksheets in the workbook");
my $worksheets;
foreach my $worksheet ($workbook->worksheets()) {
	my $worksheet_name = $worksheet->get_name;
	if (index($worksheet_name,"Map Cijferdatabank-Indicator", 0) > -1) {
		$worksheets->{$worksheet_name} = $worksheet;
		$log->debug("Ready to load worksheet: $worksheet_name");
		import_sheet($worksheet, $dbh, $table);
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
