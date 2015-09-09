__author__ = 'Dirk Vermeylen'

"""
This script will load the database into a text file. This allows to migrate the database
to a Solaris environment.
"""

import logging
import sqlite3
from lib import my_env
from time import strftime

now = strftime("%H:%M:%S %d-%m-%Y")


# Get ini-file first.
projectname = 'mowdr'
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname)
# Now configure logfile
my_env.init_logfile(config, modulename)
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
