__author__ = 'Dirk Vermeylen'

"""
This module consolidates all local configuration for the script, including modulename collection for logfile name
setup and initializing the config file.
.
"""

import configparser
import datetime
import logging
import os
import sys


def get_modulename(scriptname):
    """
    Modulename is required for logfile and for properties file.
    :param scriptname: Name of the script for which modulename is required. Use __file__.
    :return: Module Filename from the calling script.
    """
    # Extract calling application name
    (filepath, filename) = os.path.split(scriptname)
    (module, fileext) = os.path.splitext(filename)
    return module


def init_logfile(config, modulename):
    """
    This function initializes the logfile. Logfilename consists of calling module name + computername + date.
    Logfile directory is read from the project .ini file.
    Format of the logmessage is specified in basicConfig function.
    :param config: Reference to the configuration ini file. Directory for logfile should be
    in section Main entry logdir.
    :param modulename: The name of the module. Each module will create it's own logfile.
    :return: Directory and name of the logfile includint computername.
    """
    logdir = config['Main']['logdir']
    # Current Date for filename
    currdate = datetime.date.today().strftime("%Y%m%d")
    # Extract Computername
    computername = os.environ.get("COMPUTERNAME")
    # Define logfileName
    logfile = logdir + "/" + modulename + "_" + computername + \
        "_" + currdate + ".log"
    logging.basicConfig(format='%(asctime)s:%(module)s:%(funcName)s:%(lineno)d:%(levelname)s:%(message)s',
                    datefmt='%d/%m/%Y %H:%M:%S', filename=logfile, level=logging.DEBUG)
    return logfile


def get_inifile(projectname):
    """
    Read Project configuration ini file in subdirectory properties.
    :param projectname: Name of the project.
    :return: Object reference to the inifile.
    """
    # Use Project Name as ini file.
    # TODO: review procedure to get directory name instead of relative properties/ path.
    configfile = "properties/" + projectname + ".ini"
    ini_config = configparser.ConfigParser()
    try:
        ini_config.read_file(open(configfile))
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Read Inifile not successful: %s (%s)"
        print(log_msg % (e, ec))
        sys.exit(1)
    return ini_config
