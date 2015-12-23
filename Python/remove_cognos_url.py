#!/opt/csw/bin/python3

"""
This script will remove url_cognos and url_id from indicators table for specific indicator IDs. This is as a work-around
while implementing PublicCognos handling.
"""

import logging
from Datastore import Datatstore
from lib import my_env


# Set-up environment
indic_id = 11

# Get ini-file first.
projectname = 'mowdr'
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname, __file__)
# Now configure logfile
my_env.init_logfile(config, modulename)
logging.info('Start Application')
# Get Datastore handle
ds = Datatstore(config)
ds.remove_indicator_attribute(indic_id, 'url_cognos')
ds.remove_indicator_attribute(indic_id, 'id_cognos')
logging.info('End Application')
