#!/opt/csw/bin/python3

"""
This script will find Cognos Redirect files from scan directory, put them on FTP Repository and
move them to the handle directory.
The Evaluate_Cognos script will run on Vo network without proxy while moving to FTP Repository needs
the proxy settings.
"""

import logging
import os
from Ftp_Handler import Ftp_Handler
from lib import my_env
# Initialize Environment
projectname = "mowdr"
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname, __file__)
my_log = my_env.init_loghandler(config, modulename)
my_log.info('Start Application')

ftp = Ftp_Handler(config)
scandir = config['Main']['scandir']
handledir = config['Main']['handledir']
pc_prefix = config['OpenData']['public_cognos_prefix']

filelist = [file for file in os.listdir(scandir) if pc_prefix in file]
for file in filelist:
    redirect_file = os.path.join(scandir, file)
    logging.info("File {f} to FTP Repository.".format(f=file))
    ftp.load_file(redirect_file)
    logging.info("Move file {f} from {i} to {o}".format(f=file, i=scandir, o=handledir))
    my_env.move_file(file, scandir, handledir)
