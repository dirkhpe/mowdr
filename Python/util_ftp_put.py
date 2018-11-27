#!/opt/csw/bin/python3

"""
This script will move files to the FTP server.
"""

import argparse
from Ftp_Handler import Ftp_Handler
from lib import my_env

# Initialize Environment
projectname = "mowdr"
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname, __file__)
my_log = my_env.init_loghandler(config, modulename)
my_log.info('Start Application')

parser = argparse.ArgumentParser(description="Put a file on the default FTP Location")
parser.add_argument("-f", "--fileName", type=str, required=True,
                    help="Please provide file (full path name) to be moved.")

args = parser.parse_args()
my_log.info("Arguments: {a}".format(a=args))

fn = args.fileName
ftp = Ftp_Handler(config)
ftp.load_file(fn)

