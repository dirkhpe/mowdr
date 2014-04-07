# ==========================================================================
# $Source$
# $Author$ [pauwel]
# $Date$
# CDate: Thu Jun 14 16:33:14 2012
# $Revision$
#
# ==========================================================================
#
# ident "$Id$"
#
# ==========================================================================

=pod

setup_logging:

I want to be able to setup the log directory, so that the perl scripts can run on DOS and on UNIX.
Currently, I can pass logdir and I can pass ini-file parameters. This is confusing.

I will make an ALU specific ini-file subroutine. Use this routine to get the LOGDIR parameter from the current section or from the default section, and pass this parameter to the setup_logging subroutine.

This way there is no dependency on the ALU specific ini file, and the subroutine setup_logging becomes more generic.

=cut


package LogUtil;

use strict;
use warnings;
use Carp;
use File::Basename;
use File::Spec;
use Config::IniFiles;
use Cwd;
use Log::Log4perl qw(:easy :levels);
use Sys::Hostname;	    # Get Hostname
use IniUtil qw(get_ini);
use Data::Dumper;

BEGIN {
  use Exporter ();
  our ($VERSION, @ISA, @EXPORT, @EXPORT_OK);
  $VERSION	 = '1.0';
  @ISA       = qw(Exporter);
  @EXPORT    = qw();
  @EXPORT_OK = qw(setup_logging);
}

# ==========================================================================


=item setup_logging( { ini_section => SECTION, logdir => LOGDIR, level => LEVEL, quiet => 1 } ])

 Levels :
   OFF, FATAL, ERROR, WARN, INFO, DEBUG, TRACE, ALL

 Logging setup
  Alle FATAL, ERROR, WARN gaat naar STDERR
  Alles (FATAL, ERROR, WARN, INFO, DEBUG, TRACE) gaat naar file (en deze file moet roteren)
  Een summary.log met daarin alle uitgevoerde jobs + return status.

Voor InfoBox had ik ooit een scaler appender gemaakt, waarbij de logging opgespaard werd tot het einde.
Dit doe ik nu niet. Beter gewoon logging onmiddelijk doorgeven.

Default ini_section is 'DEFAULT'
Default logdir is 'c:\temp\log'
Default level is WARN

TODO :
DEBUG gaat momenteel enkel naar trace file (en niet naar scherm !)

=cut

sub setup_logging {
  confess "usage: setup_logging([ options ])" unless @_ < 2;

  my $attr  = shift || {};

  # overschrijven met info uit de alu.ini (als die bestaat)
  # Daarmee kan ik ook aan mijn unix folders

  my $INI_SECTION = (exists $attr->{ini_section}) ? $attr->{ini_section} : 'DEFAULT';

  ## Lees de project.ini file
  my $cfg = get_ini();

  my $ini_logdir;
  if (defined $cfg) {
    if ($cfg->SectionExists($INI_SECTION)) {
      if ($cfg->val($INI_SECTION, 'LOGDIR')) {
        $ini_logdir = $cfg->val($INI_SECTION, 'LOGDIR');
      }
    } else {
      print STDERR "ERROR: ini section `$INI_SECTION' does not exist!\n";
    }
  }

  # we fall back on c:\temp\log if there is no usable ini file
  my $logdir = (defined $ini_logdir) ? $ini_logdir : 'c:\temp\log';

  if (exists $attr->{logdir}) {
    my $d = $attr->{logdir};
    unless (-d $d) {
      print STDERR "ERROR: log directory `$d' does not exist ! Using default ($logdir)\n";
    } else {
      $logdir = $d;
    }
  }

  unless (-d $logdir) {
    print STDERR "ERROR: log directory `$logdir' does not exist ! Exiting ...\n";
    exit(1);
  }

  my $opt_level = 0;

  if (exists $attr->{level}) {
    $opt_level = $attr->{level};
  }

  my $opt_quiet = 0;

  if (exists $attr->{quiet} && $attr->{quiet}) {
    $opt_quiet = 1;
  }

  # Steek de logging in dezelfde files als Dirk zijn logging

  my $scriptname = basename($0, '.pl', '.PL');
  my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  my $computername = hostname() ? hostname() : "undefinedComputer";
  my $basename = sprintf("${scriptname}_${computername}_%04d%02d%02d", $year+1900, $mon+1, $mday);

#  my $summary_file = File::Spec->catfile($logdir, 'summary.log');
#  my $data_file = File::Spec->catfile($logdir, 'data.log');
#  my $trace_file = File::Spec->catfile($logdir, 'trace.log');
#  my $default_file = File::Spec->catfile($logdir, 'default.log');

  my $summary_file = File::Spec->catfile($logdir, "${basename}.summary.log");
  my $data_file = File::Spec->catfile($logdir, "${basename}.data.log");
  my $trace_file = File::Spec->catfile($logdir, "${basename}.trace.log");
  my $default_file = File::Spec->catfile($logdir, "${basename}.log");

  use Log::Log4perl::Appender;
  use Log::Log4perl::Layout::PatternLayout;
  use Log::Log4perl::Filter::LevelRange;

  # Define a  pattern layout
  # %d - date and time
  # %c - Category of the logging event.
  # %C - Fully qualified package (or class) name of the caller
  # %l - Fully qualified name of the calling method followed by the callers source the file name and line number between parentheses.
  # %p - Priority of the logging event (%p{1} shows the first letter)
  # %m - The message to be logged
  # %n - Newline (OS-independent)
  # my $pattern = "%d %c %C %l> %p: %m%n";
  # my $pattern = "%-6P %d{dd/MM/yyyy HH:mm:ss} (%08Rms) %m%n";

  my $pattern = "%d (%P) %p: %M{3}[%L]: %m%n";

  # FATAL .. WARN => STDERR
  # mogelijk alternatief pattern : log4perl.appender.StderrAppender.layout    = Log::Log4perl::Layout::SimpleLayout

  my $stderr_appender = "
        log4perl.filter.StderrFilter               = Log::Log4perl::Filter::LevelRange
        log4perl.filter.StderrFilter.LevelMin      = DEBUG
        log4perl.filter.StderrFilter.LevelMax      = FATAL
        log4perl.filter.StderrFilter.AcceptOnMatch = true

        log4perl.appender.StderrAppender           = Log::Log4perl::Appender::Screen
        log4perl.appender.StderrAppender.utf8      = 1
        log4perl.appender.StderrAppender.stderr    = 1
        log4perl.appender.StderrAppender.layout    = PatternLayout
        log4perl.appender.StderrAppender.layout.ConversionPattern = $pattern
        log4perl.appender.StderrAppender.Filter    = StderrFilter\n";

  # log enkel INFO messages in de Category 'Summary'
  my $summary_category = "
        log4perl.filter.SummaryFilter = Log::Log4perl::Filter::LevelMatch
        log4perl.filter.SummaryFilter.LevelToMatch = INFO
        log4perl.filter.SummaryFilter.AcceptOnMatch = true

        log4perl.appender.SummaryStdoutAppender           = Log::Log4perl::Appender::Screen
        log4perl.appender.SummaryStdoutAppender.utf8      = 1
        log4perl.appender.SummaryStdoutAppender.stderr    = 0
        log4perl.appender.SummaryStdoutAppender.layout    = PatternLayout
        log4perl.appender.SummaryStdoutAppender.layout.ConversionPattern = SUMMARY %d %p: %m%n
        log4perl.appender.SummaryStdoutAppender.Filter    = SummaryFilter

        log4perl.appender.SummaryAppender           = Log::Log4perl::Appender::File
        log4perl.appender.SummaryAppender.filename  = $summary_file
        log4perl.appender.SummaryAppender.mode      = append
        log4perl.appender.SummaryAppender.umask     = 0002
        log4perl.appender.SummaryAppender.utf8      = 1
        log4perl.appender.SummaryAppender.layout    = PatternLayout
        log4perl.appender.SummaryAppender.layout.ConversionPattern = %d (%P) %p: (%08Rms) %m%n
        log4perl.appender.SummaryAppender.Filter    = SummaryFilter

        log4perl.category.Summary = INFO, SummaryAppender, SummaryStdoutAppender
        log4perl.additivity.Summary = 0
";


  # log alle messages in de Category 'Data' vanaf het INFO level
  # We loggen enkel de message en niks anders (timestamps ed. zitten reeds in de datastage log message)
  # Met deze setup loggen we zowel naar file als naar stdout.
  # Het ware beter bij interactief starten => stdout en bij "batch" verwerking => file

  my $data_pattern = "";

  my $data_category = "
        log4perl.filter.DataFilter               = Log::Log4perl::Filter::LevelRange
        log4perl.filter.DataFilter.LevelMin      = INFO
        log4perl.filter.DataFilter.LevelMax      = FATAL
        log4perl.filter.DataFilter.AcceptOnMatch = true

        log4perl.appender.DataStdoutAppender           = Log::Log4perl::Appender::Screen
        log4perl.appender.DataStdoutAppender.utf8      = 1
        log4perl.appender.DataStdoutAppender.stderr    = 0
        log4perl.appender.DataStdoutAppender.layout    = PatternLayout
        log4perl.appender.DataStdoutAppender.layout.ConversionPattern = DATA    %d %p: %M{3}[%L]: %m%n
        log4perl.appender.DataStdoutAppender.Filter    = DataFilter

        log4perl.appender.DataAppender           = Log::Log4perl::Appender::File
        log4perl.appender.DataAppender.filename  = $data_file
        log4perl.appender.DataAppender.mode      = append
        log4perl.appender.DataAppender.umask     = 0002
        log4perl.appender.DataAppender.utf8      = 1
        log4perl.appender.DataAppender.layout    = PatternLayout
        log4perl.appender.DataAppender.layout.ConversionPattern = %d %p: %M{3}[%L]: %m%n
        log4perl.appender.DataAppender.Filter    = DataFilter

        log4perl.category.Data = INFO, DataAppender, DataStdoutAppender
        log4perl.additivity.Data = 0
";

  # Initialize logging behaviour

  # default staat het level van de root logger op WARN
  # FATAL, ERROR, WARN, INFO, DEBUG, and TRACE

  my $conf = "
        log4perl.rootLogger                = WARN, StderrAppender
        $stderr_appender
        $summary_category
        $data_category
    ";

  Log::Log4perl::Config->allow_code(0); # security wise, don't allow te execute code

  # Log::Log4perl->init_once(\$conf);
  # Overschrijf de initialisatie die gedaan was met easy_init, anders werkt mijn summary.log niet meer
  Log::Log4perl->init(\$conf);

  # doe STDOUT appenders weg
  if ($opt_quiet) {
      my $summary_log = Log::Log4perl->get_logger('Summary');
      $summary_log->remove_appender('SummaryStdoutAppender');

      my $data_log = Log::Log4perl->get_logger('Data');
      $data_log->remove_appender('DataStdoutAppender');
  }

  #
  # Add logging to file for the root logger
  #

  my $root_logger = Log::Log4perl->get_logger('');

  # -v => level = 1, -v -v => level = 2
  if ($opt_level >= 1) {
    $root_logger->more_logging($opt_level);
  }

  # Bijkomend alle logging capteren in een file

  # Om een of andere reden kan je noch de layout, noch de filter in de meegeven met de new methode.
  # Allez, je kan ze wel meegeven, maar het doet niks.

  my $file_appender = Log::Log4perl::Appender->new('Log::Log4perl::Appender::File', name => "file appender", umask => 0002, utf8 => 1, filename => "$default_file", mode => 'append');
  $file_appender->layout( Log::Log4perl::Layout::PatternLayout->new($pattern) );
  $root_logger->add_appender($file_appender);

  # extra logging for trace purposes (laagste cijfer => meeste logging)
  if ($root_logger->level() <= $TRACE) {
    my $appender = Log::Log4perl::Appender->new('Log::Log4perl::Appender::File',
                                                name => "trace file appender",
                                                umask => 0002,
                                                utf8 => 1,
                                                filename => "$trace_file",
                                                mode => 'append');

    # Assign the layout with trace info
    $appender->layout( Log::Log4perl::Layout::PatternLayout->new("%d (%P) %p: (%05R ms) %M{3}[%L]: %m%n") );

    $root_logger->add_appender($appender);
  }

  return 1;

}

1;
