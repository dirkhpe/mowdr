#!/opt/csw/bin/python3

import os
import subprocess
from FileHandler import FileHandler
from lib import my_env

# Initialize Environment
projectname = "mowdr"
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname, __file__)
my_log = my_env.init_loghandler(config, modulename)
my_log.info('Start Application')
scriptdir = config['Main']['scriptdir']
# Evaluate_Cognos.py needs to run on Vo network, no proxy allowed
scriptname = 'Evaluate_Cognos.py'
cmdline = scriptdir + scriptname
subprocess.call(cmdline)
scriptname = 'Add_Cognos_Resource.py'
cmdline = scriptdir + scriptname
subprocess.call(cmdline)
# Get FileHandler Object
fh = FileHandler(config)
# Check for proxyserver
# Proxy can be enabled now.
try:
    http_proxy = config['Main']['proxy']
except KeyError:  # http_proxy not defined, continue
    pass
else:
    os.environ['http_proxy'] = http_proxy
    my_log.info("Set proxy to %s", http_proxy)
fh.process_input_directory()
my_log.info("End Application")