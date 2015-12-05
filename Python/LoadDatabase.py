__author__ = 'Dirk Vermeylen'

"""
This script will load the database into a text file. This allows to migrate the database
to a Solaris environment.
"""

import configparser
import datetime
import logging
import os
import platform
import sqlite3
import sys
from time import strftime

now = strftime("%H:%M:%S %d-%m-%Y")


def get_modulename():
    """
    Modulename is required for logfile and for properties file.
    :return: Module Filename (HandleFile in this case).
    """
    # Extract calling application name
    (filepath, filename) = os.path.split(sys.argv[0])
    (module, fileext) = os.path.splitext(filename)
    return module


def get_inifile():
    # Use Project Name as ini file.
    projectname = 'mowdr'
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


def get_logfilename():
    """
    Temporary function to define Logfile Name.
    :return: Name of the logfile.
    """
    logdir = config['Main']['logdir']
    # Current Date for filename
    currdate = datetime.date.today().strftime("%Y%m%d")
    # Extract Computername
    computername = platform.node()
    # Define logfileName
    logfile = logdir + "/" + modulename + "_" + computername + \
        "_" + currdate + ".log"
    return logfile


# Get ini-file first.
modulename = get_modulename()
config = get_inifile()
# Now configure logfile
logfilename = get_logfilename()
logging.basicConfig(format='%(asctime)s:%(module)s:%(funcName)s:%(lineno)d:%(levelname)s:%(message)s',
                    datefmt='%d/%m/%Y %H:%M:%S', filename=logfilename, level=logging.DEBUG)
logging.info('Start Application')
logging.info('Get Database connection')
db = config['Main']['db']
con = sqlite3.connect(db)
logging.info('Now load the database')
f = open('dump.sql')
sql = f.read()
con.executescript(sql)
logging.info('Load database done.')
logging.info('End Application')

