#!/opt/csw/bin/python3

import logging
import sys
from ftplib import FTP
from lib import my_env


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
    ftpdir = config['FTPServer']['dir']
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
        sys.exit(1)
    try:
        log_msg = "Login at FTP Server"
        logging.debug(log_msg)
        ftp.login(user=user, passwd=passwd)
    except:
        ec = sys.exc_info()[0]
        e = sys.exc_info()[1]
        log_msg = "Error during FTP login: %s %s \n\n"
        logging.critical(log_msg, e, ec)
        sys.exit(1)
    try:
        log_msg = "Change Directory"
        logging.debug(log_msg)
        ftp.cwd(ftpdir)
    except:
        ec = sys.exc_info()[0]
        e = sys.exc_info()[1]
        log_msg = "Error during FTP cwd: %s %s \n\n"
        logging.critical(log_msg, e, ec)
        sys.exit('FTP CWD failed')
    log_msg = "Connection and cwd to FTP server seems to be successful"
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
# os.environ['http_proxy'] = 'http://proxyservers.vlaanderen.be:8080'
projectname = 'mowdr'
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname)
# Now configure logfile
my_env.init_logfile(config, modulename)
logging.info('Start Application')
logdir = config['Main']['logdir']
outfile = logdir + "/" + modulename + ".txt"
f = open(outfile, 'w')
ftp_obj = ftp_connection()
logmsg = "FTP Connection is there, now try to get welcome message."
logging.debug(logmsg)
ftp_get_welcome(ftp_obj)
ftp_dir(ftp_obj)
ftp_obj.close()
f.close()
logging.info('End Application')
