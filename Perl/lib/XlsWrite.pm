# ==========================================================================
# $Source$
# $Author$ [pauwel]
# $Date$
# CDate: Wed Jul 11 13:30:01 2012
# $Revision$
#
# ==========================================================================
#
# ident "$Id$"
#
# ==========================================================================

=pod

Set of routines to write a table to an excel spreadsheet.

=cut

package XlsWrite;

use strict;
use warnings;
use Carp;
use Log::Log4perl qw(:easy get_logger);
use Spreadsheet::WriteExcel;
use IniUtil qw(get_ini);

use DbUtil qw(do_select);

use Data::Dumper;

BEGIN {
  use Exporter ();
  our ($VERSION, @ISA, @EXPORT, @EXPORT_OK);

  $VERSION = '1.0';
  @ISA         = qw(Exporter);
  @EXPORT    = qw();
  @EXPORT_OK = qw( write_table
                );
}

=pod

=head2 Write Table

This procedure will export a table in excel format. All rows from the table are exported. The column names from the table are the column names in excel.

The project ini file needs to have a [REPORTS] section, with a reportdir variable (directory where the output files will be stored). In case the ini file has an entry for I<tablename> in the REPORTS section, then this value will be used for the report name.

The required columns from the table need to be specified in an arrayref, in the sequence that the columns are needed.

Existing files will be overwritten.

=cut

sub write_table {
	LOGCONFESS("usage: write_table(dbh, table, columns)") unless @_ == 3;

	my ($dbh, $table, $columns_ref) = @_;
	
	my $reports = "REPORTS";
	my $reportdir = "c:/temp";
	my $reportname = $table;
	my $worksheet_name = $table;

	my $cfg = get_ini();
	my $log = get_logger();

	# Get table contents
	my $selectstr = join (", ", map { $_ } @$columns_ref);
	my $query = "SELECT $selectstr FROM $table";
	my $ref = do_select($dbh, $query);

	# Verify that I'm not trying to convert an empty table
	unless ((defined $ref) && (@$ref > 0)) {
		$log->warn("Trying to export empty table $table to excel");
		return;
	}

	if (defined $cfg) {
		if ($cfg->SectionExists("REPORTS")) {
			if ($cfg->val($reports, 'reportdir')) {
				$reportdir = $cfg->val($reports, 'reportdir');
			}
			if ($cfg->val($reports, $table)) {
				$reportname = $cfg->val($reports, $table);
			}
			if ($cfg->val($reports, $table . "_tab1")) {
				$worksheet_name = $cfg->val($reports, $table . "_tab1");
			}
		}
	}

	my $file = "$reportdir/$reportname.xls";

	# Create a new workbook
	my $workbook = Spreadsheet::WriteExcel->new($file);
	unless ($workbook) {
		$log->error("Could not create Excel Workbook $file");
		return;
	}

	# Add worksheet to the workbook
	my $worksheet = $workbook->add_worksheet($worksheet_name);
	unless ($worksheet) {
		$log->error("Could not add worksheet $worksheet_name to Excel Workbook $file.");
		return;
	}

	# Format Worksheet header
	my $header_format = $workbook->add_format() or die;
	$header_format->set_bold();
	$header_format->set_bg_color('yellow');
	$header_format->set_align('center');

	# The general syntax is write($row, $column, $token).
	# Note that row and column are zero indexed.

	my $iR = 0;
	my $l;

	# Write the header line
	for my $iC (0 .. $#$columns_ref) {
	  my $col = @$columns_ref[$iC];
	  $worksheet->write($iR, $iC, $col, $header_format) and die;
	  $l->[$iC] = length($col);
	}

	$iR++;

	# Write the data
	foreach my $row (@$ref) {
		for my $iC (0 .. $#$columns_ref) {
			my $col = @$columns_ref[$iC];
			my $elem = $$row{$col};
			unless (defined $elem) {
				$elem = "";
			}
			$worksheet->write($iR, $iC, $elem) and die;
			$l->[$iC] = length($elem) if (length($elem) > $l->[$iC]);
			$iC++;
		}
		$iR++;
	}

	# Set the column widths
	my $col_width;
	for my $iC (0 .. $#$columns_ref) {
		if ($l->[$iC] < 60) {
			$col_width = $l->[$iC];
		} else {
			$col_width = 60;
		}
		$worksheet->set_column($iC, $iC, $col_width);
	}

	unless ($workbook->close()) {
		$log->error("Could not close workbook $file");
		return;
	}

	return $iR;
}

1;
