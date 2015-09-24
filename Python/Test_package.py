__author__ = 'Dirk Vermeylen'

import json
import logging
import os
import sys
import ckanapi
from ftplib import FTP
from lib import my_env


def package_show(package_name):
    """
    URL: http://ckan-001.corve.openminds.be/api/3/action/package_show?
    id=dmow-ind003-filezwaarte_op_het_hoofdwegennet&include_tracking=True
    Return the metadata of a dataset (package) and its resources.
    :param package_name:
    :return:
    """
    if package_name is None:
        print('Package Name needs to be defined!')
    else:
        try:
            res = ckan_conn.action.package_show(id=package_name, include_tracking=1)
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Package Show not successful %s %s"
            logging.error(log_msg, e, ec)
            return False
        else:
            print("Name: " + res['name'])
            print("ID: " + res['id'])
            print("Organization: " + res['organization']['name'])
            f.write('Result of package_show:\n')
            f.write('-----------------------\n')
            f.write(json.dumps(res, indent=4))
            f.write('\n\n\n')
            logging.info("Output written to " + outfile)


def package_list():
    """
    URL: http://ckan-001.corve.openminds.be/api/3/action/package_list
    Return the metadata of a dataset (package) and its resources.
    :return:
    """
    try:
        res = ckan_conn.action.package_list(limit=20)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Package List not successful %s %s"
        logging.error(log_msg, e, ec)
        return False
    else:
        f.write('Result of package_list:\n')
        f.write('-----------------------\n')
        f.write(json.dumps(res, indent=4))
        f.write('\n\n\n')


def get_ckan_conn():
    """
    Configure the connection to ckan Open Data Platform.
    :return:
    """
    logging.debug("Setup connection to ckan Server")
    url = config['CKANServer']['url']
    api = config['CKANServer']['api']
    try:
        ckanconn = ckanapi.RemoteCKAN(url, apikey=api)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Connect to RemoteCKAN not successful %s %s"
        logging.critical(log_msg, e, ec)
        sys.exit(1)
    return ckanconn


def ftp_connection():
    """
    This procedure establishes an FTP connection to the FTP Server.
    :return: ftp object.
    """
    log_msg = "Trying to establish FTP Connection"
    logging.debug(log_msg)
    host = config['FTPServer']['host']
    user = config['FTPServer']['user']
    passwd = config['FTPServer']['passwd']
    ftp = FTP()
    try:
        log_msg = "Connect to FTP Server"
        logging.debug(log_msg)
        # ftp.connect(host=host, port=8080, timeout=10)
        ftp.connect(host=host, timeout=10)
    except:
        ec = sys.exc_info()[0]
        e = sys.exc_info()[1]
        log_msg = "Error during FTP connect: %s %s \n\n"
        logging.critical(log_msg, e, ec)
        exit()
    try:
        log_msg = "Login at FTP Server"
        logging.debug(log_msg)
        ftp.login(user=user, passwd=passwd)
    except:
        ec = sys.exc_info()[0]
        e = sys.exc_info()[1]
        log_msg = "Error during FTP login: %s %s \n\n"
        logging.critical(log_msg, e, ec)
        exit()
    log_msg = "Connection to FTP server seems to be successful"
    logging.debug(log_msg)
    return ftp


def ftp_get_welcome(ftp):
    try:
        welcome = ftp.getwelcome()
    except:
        ec = sys.exc_info()[0]
        e = sys.exc_info()[1]
        log_msg = "Error get welcome from FTP Server: %s %s"
        logging.critical(log_msg, e, ec)
        return
    else:
        f.write('Result of FTP Welcome message:\n')
        f.write('------------------------------\n')
        f.write(welcome)
        f.write('\n\n\n')
        return


def ftp_dir(ftp):
    try:
        dir_list = ftp.mlsd()
    except:
        ec = sys.exc_info()[0]
        e = sys.exc_info()[1]
        log_msg = "Error get welcome from FTP Server: %s %s"
        logging.critical(log_msg, e, ec)
        return
    else:
        f.write('Result of FTP Directory list:\n')
        f.write('-----------------------------\n')
        for (file, facts) in dir_list:
            f.write(file + " - " + str(facts) + "\n")
        f.write("\n\n\n")
        return


# Get ini-file first.
# Setup Proxy Server
os.environ['http_proxy'] = 'http://proxyservers.vlaanderen.be:8080'
projectname = 'mowdr'
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname)
# Now configure logfile
my_env.init_logfile(config, modulename)
logging.info('Start Application')
ckan_conn = get_ckan_conn()
logdir = config['Main']['logdir']
outfile = logdir + "/Test_package.txt"
f = open(outfile, 'w')
package_show('dmow-ind003-filezwaarte_op_het_hoofdwegennet')
# package_show('faillissementen2')
package_list()
ftp_obj = ftp_connection()
log_msg = "FTP Connection is there, now try to get welcome message."
logging.debug(log_msg)
ftp_get_welcome(ftp_obj)
ftp_dir(ftp_obj)
ftp_obj.close()
f.close()
logging.info('End Application')

