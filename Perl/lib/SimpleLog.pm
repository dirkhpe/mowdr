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

I will make an ALU specific ini-file subroutine. Use this routine to get the Logdir parameter from the current section or from the default section, and pass this parameter to the setup_logging subroutine.

This way there is no dependency on the ALU specific ini file, and the subroutine setup_logging becomes more generic.

=cut


package SimpleLog;

use strict;
use warnings;
use Carp;
use File::Basename;
use File::Spec;
use Config::IniFiles;
use Cwd;
use Log::Log4perl qw(get_logger :levels);
use Log::Log4perl::Appender::File;
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


=item setup_logging( { ini_section => SECTION, logdir => Logdir, level => LEVEL, quiet => 1 } ])

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

  my ($ini_logdir, $ini_loglevel);
  if (defined $cfg) {
    if ($cfg->SectionExists($INI_SECTION)) {
	  # Get log directory
      if ($cfg->val($INI_SECTION, 'Logdir')) {
        $ini_logdir = $cfg->val($INI_SECTION, 'Logdir');
      }
	  if ($cfg->val($INI_SECTION, 'LogLevel')) {
		$ini_loglevel = $cfg->val($INI_SECTION, 'LogLevel');
	  }
    } else {
      print STDERR "ERROR: ini section `$INI_SECTION' does not exist!\n";
    }
  }

  # we fall back on c:\temp\log if there is no usable ini file
  my $logdir = (defined $ini_logdir) ? $ini_logdir : 'c:\temp\log';
  my $loglevel = (defined $ini_loglevel) ? $ini_loglevel : "DEBUG";

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

  my $scriptname = basename($0, '.pl', '.PL');
  my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  my $computername = hostname() ? hostname() : "undefinedComputer";
  my $basename = sprintf("${scriptname}_${computername}_%04d%02d%02d", $year+1900, $mon+1, $mday);
  my $logfile = File::Spec->catfile($logdir, "${basename}.log");
  

  my $generic = "
	log4perl.rootLogger=$loglevel, LOGFILE, Screen

	log4perl.appender.LOGFILE=Log::Log4perl::Appender::File
	log4perl.appender.LOGFILE.filename=$logfile
	log4perl.appender.LOGFILE.mode=append
	log4perl.appender.LOGFILE.layout=PatternLayout
	log4perl.appender.LOGFILE.layout.ConversionPattern=%d %p> %m (%M - line: %L)%n
	
	log4perl.appender.Screen=Log::Log4perl::Appender::Screen
	log4perl.appender.Screen.stderr=1
	log4perl.appender.Screen.utf8=1
	log4perl.appender.Screen.layout=PatternLayout
	log4perl.appender.Screen.layout.ConversionPattern=%d %p> %m (%F{1}:%L %M)%n\n";

  my $conf = "$generic";
  Log::Log4perl->init(\$conf);

  return 1;

}

1;
