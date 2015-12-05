"""
Purpose of this script is to find indicator attributes that do not show up in attributes_action table.
"""
import logging
from lib import my_env
from Datastore import Datatstore

# Initialize Environment
projectname = "mowdr"
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname)
my_env.init_logfile(config, modulename)
# Now go for it
logging.info('\n\n\nStart Application')
logging.info('Initialize Datastore object')
ds = Datatstore(config)
ds.db_consistency()
# Add Records to indicator table
logging.info('Close Database connection')
ds.close_connection()
# Todo destroy object?
logging.info('End Application')
