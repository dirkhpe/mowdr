#!/opt/csw/bin/python3

import os
from FileHandler import FileHandler
from lib import my_env

# Initialize Environment
projectname = "mowdr"
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname, __file__)
my_log = my_env.init_loghandler(config, modulename)
my_log.info('Start Application')
# Get FileHandler Object
fh = FileHandler(config)
# Check for proxyserver
try:
    http_proxy = config['Main']['proxy']
except KeyError:  # http_proxy not defined, continue
    pass
else:
    os.environ['http_proxy'] = http_proxy
    my_log.info("Set proxy to %s", http_proxy)
fh.process_input_directory()
my_log.info("End Application")
