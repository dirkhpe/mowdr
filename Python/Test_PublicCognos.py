#!/opt/csw/bin/python3

import logging
from lib import my_env
# from Ftp_Handler import Ftp_Handler
from PublicCognos import PublicCognos

# Initialize Environment
projectname = "mowdr"
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname, __file__)
my_env.init_logfile(config, modulename)
# Now go for it
indics = [('filezwaarte op het hoofdwegennet', 3),
          ('filezwaarte op het zijwegennet', 15),
#          ('voertuigenpark (de lijn)', 112),
          ('verdeling van verplaatsingen volgens verplaatsingsmotief', 901901)]
logging.info('Start Application')
# ftp = Ftp_Handler(config)
for indic_name, indic_id in indics:
    # Check if Public Cognos URL exists
    print("Evaluate " + indic_name)
    pc_url = PublicCognos(indic_name)
    # get redirect_file and redirect_page
    redirect_file, redirect_url = pc_url.redirect2cognos_page(indic_id, config)
#    ftp.load_file(redirect_file)
    # if pc_url.check_if_cognos_report_exists():
    # Now check how redirect page behaves
    if pc_url.check_if_cognos_report_exists():
        print("Public Cognos URL exists for " + indic_name)
        # redirect_file, redirect_url = pc_url.redirect2cognos_page(indic_id, config)
        # print("Loaded Redirect Page on " + redirect_url)
    else:
        print("Public Cognos Page not found for " + indic_name)
logging.info('End Application')
