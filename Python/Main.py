#!/opt/csw/bin/python3

import logging
from FileHandler import FileHandler
from lib import my_env

# Initialize Environment
projectname = "mowdr"
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname)
my_env.init_logfile(config, modulename)
logging.info('\n\n\nStart Application')
# Get FileHandler Object
fh = FileHandler(config)
# Set up Proxy Server
# os.environ['http_proxy'] = 'http://proxyservers.vlaanderen.be:8080'
# Scan every file in the input directory and process it
logging.info('Processing Input Dir')
fh.process_input_directory()
logging.info('End Application')
