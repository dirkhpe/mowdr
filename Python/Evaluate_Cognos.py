#!/opt/csw/bin/python3

"""
This script will find all indicators for which Cognos report is not yet available.
The script will check for Cognos report on vobip public cognos URL.
If the report is published, then the Cognos URL (for the redirect page) will be added to the indicators table.
The script Add_Cognos_Resource.py will then add the resources to Open Data platform.

This script used to be a module in the FileHandler class. But check on Cognos URL failed on Solaris 5.10 with
'Forbidden' (403) error message. The message did not show up on Windows. Also on Solaris 5.10 the separate components
worked fine, only combination seems to fail.
PROBLEM SOLVED - The error occurs when the Proxy server is set. Check on Public Cognos needs to be done on internal
network. So execute this script before setting the proxy server.
"""
from Datastore import Datastore
from Ftp_Handler import Ftp_Handler
from PublicCognos import PublicCognos
from lib import my_env

# Initialize Environment
projectname = "mowdr"
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname, __file__)
my_log = my_env.init_loghandler(config, modulename)
my_log.info('Start Application')
ds = Datastore(config)
ftp = Ftp_Handler(config)
for indic_id in ds.get_indicator_ids():
    if not ds.check_resource(indic_id, "cognos"):
        indicatorname = ds.get_indicator_value(indic_id, "title")[0][0]
        # Verify if Cognos URL exist on PublicCognos. Load if it does.
        pc_url = PublicCognos(indicatorname)  # Get my PublicCognos URL Object
        # Check if Cognos Public URL exists
        if pc_url.check_if_cognos_report_exists():
            # get redirect_file and redirect_page.
            redirect_file, redirect_url = pc_url.redirect2cognos_page(indic_id, config)
            # Load Cognos Redirect page on FTP Repository.
            ftp.load_file(redirect_file)
            # Add Cognos URL to indicators table. Cognos Resource ID (id_cognos) is not available as long as package
            # has not been created.
            ds.insert_indicator(indic_id, 'url_cognos', redirect_url)
my_log.info("End Application")
