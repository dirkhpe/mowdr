__author__ = 'Dirk Vermeylen'

"""
This is the main application to handle files from Dataroom and
process them for loading on the Open Data Platform.
"""

import configparser
import datetime
from ftplib import FTP
import logging
import os
import re
import sys
# import ManageOpenData as Mod
# import ManageResource as Mr


def get_modulename():
    """
    Modulename is required for logfile and for properties file.
    :return: Module Filename (HandleFile in this case).
    """
    # Extract calling application name
    (filepath, filename) = os.path.split(sys.argv[0])
    (modulename, fileext) = os.path.splitext(filename)
    return modulename


def get_inifile():
    # Use Project Name as ini file.
    projectname = 'mowdr'
    configfile = "properties/" + projectname + ".ini"
    config = configparser.ConfigParser()
    try:
        config.read_file(open(configfile))
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Read Inifile not successful: %s (%s)"
        print(log_msg % (e, ec))
        sys.exit(1)
    return config


def get_logfilename(modulename, config):
    """
    Temporary function to define Logfile Name.
    :return: Name of the logfile.
    """
    logdir = config['Main']['logdir']
    # Current Date for filename
    currdate = datetime.date.today().strftime("%Y%m%d")
    # Extract Computername
    computername = os.environ.get("COMPUTERNAME")
    # Define logfileName
    logfilename = logdir + "/" + modulename + "_" + computername + \
        "_" + currdate + ".log"
    return logfilename


def ftp_connection(host, user, passwd):
    """
    This procedure establishes an FTP connection to the FTP Server.
    :return: ftp object.
    """
    log_msg = "Trying to establish FTP Connection"
    logging.debug(log_msg)
    try:
        ftp = FTP(host=host, user=user, passwd=passwd)
    except:
        ec = sys.exc_info()[0]
        e = sys.exc_info()[1]
        log_msg = "Error during connect to FTP Server: %s %s"
        logging.critical(log_msg, e, ec)
        return
    return ftp


def load_file(ftp, file=None):
    """
    Load file on mobielvlaanderen.be. Remove the file first if it exists already (since it is an older version).
    If remove_only is True, then only remove the file.
    :param file: Filename of the file to be loaded.
    :return:
    """
    log_msg = "Moving file %s to FTP Server"
    logging.debug(log_msg, file)
    # Get Filename from file pointer
    (filepath, filename) = os.path.split(file)
    # Load the File
    try:
        f = open(file, mode='rb')
    except:
        e = sys.exc_info()[0]
        log_msg = "Error to open file %s"
        logging.critical(log_msg, e)
        return
    stor_cmd = 'STOR ' + filename
    try:
        ftp.storbinary(stor_cmd, f)
    except:
        e = sys.exc_info()[0]
        log_msg = "Error loading file: %s"
        logging.critical(log_msg, e)
        return
    log_msg = "Looks like file %s is moved to FTP Server, close file now."
    logging.debug(log_msg, file)
    f.close()
    return


def remove_file(ftp, file=None):
    """
    Remove file on mobielvlaanderen.be.
    :param file: Filename of the file to be loaded.
    :return:
    """
    log_msg = "Removing file %s from FTP Server"
    logging.debug(log_msg, file)
    # Get Filename from file pointer
    (filepath, filename) = os.path.split(file)
    filename = re.sub('empty\.', '', filename)
    log_msg = "First remove 'empty.' from filename, new filename: %s."
    logging.debug(log_msg, filename)
    # Remove the File
    try:
        ftp.delete(filename)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Error removing file: %s %s"
        logging.error(log_msg, e, ec)
        return
    log_msg = "Looks like file %s is removed from FTP Server."
    logging.debug(log_msg, file)
    return


def move_file(file2move, sourcedir, targetdir):
    """
    This function will move a file from source dir to target dir.
    It will check if the file exists on target dir. If so, remove file from target dir.
    Then move file from source dir. Assumption: file must exist on sourcedir.
    :param file2move: Filename of the file that needs to be moved
    :param sourcedir: Source Directory where the file is now.
    :param targetdir: Target Directory where the file needs to go to.
    :return:
    """
    if file2move in [file for file in os.listdir(targetdir)]:
        log_msg = "File %s exists in targetdir %s, remove first"
        logging.debug(log_msg, file2move, targetdir)
        os.remove(os.path.join(targetdir, file2move))
    log_msg = "OK, File %s does not exists in targetdir %s now."
    logging.debug(log_msg, file2move, targetdir)
    os.rename(os.path.join(sourcedir, file2move), os.path.join(targetdir, file2move))
    return


def indic_from_file(filename):
    """
    This procedure will extract the indicator ID from the filename.
    The indicator number is between _ and first . (empty. can be there as second dot.)
    :param filename:
    :return: indic_id (numeric)
    """
    log_msg = "Getting indicator ID from %s"
    logging.debug(log_msg, filename)
    parts = filename.split('_')
    indic_array = parts[1].split('.')
    indic_id = int(indic_array[0])
    log_msg = "Indicator ID: %s"
    logging.debug(log_msg, indic_id)
    return indic_id


def scan_for_files(config):
    """
    Function to scan input directory for new files in sequence: commentaar - cijfers - metadata.
    If a file is found, call file handling procedure.
    :param config: Read scan directory and handled directory from config file.
    :return:
    """
    scandir = config['Main']['scandir']
    handledir = config['Main']['handledir']
    log_msg = "Scan %s for files commentaar*.xml"
    logging.debug(log_msg, scandir)
    log_msg = "First get my FTP Connection"
    logging.debug(log_msg)
    host = config['FTPServer']['host']
    user = config['FTPServer']['user']
    passwd = config['FTPServer']['passwd']
    ftp = ftp_connection(host, user, passwd)
    # Don't use os.listdir in for loop since I'll move files. For loop will get confused.
    # Extract filelist first.
    filelist = [file for file in os.listdir(scandir) if 'cijfers' or 'commentaar' in file]
    for file in filelist:
        indic_id = indic_from_file(file)
        print("Filename: %s, Indicator ID: %s" % (file, indic_id))
        move_file(file, scandir, handledir)  # Move file done in own function, such a hassle...
        if 'empty' in file:
            remove_file(ftp, file=os.path.join(handledir, file))
        else:
            load_file(ftp, file=os.path.join(handledir, file))
    # Now close FTP Object
    ftp.close()
    return


def main():
    # Get ini-file first.
    modulename = get_modulename()
    config = get_inifile()
    # Now configure logfile
    logfilename = get_logfilename(modulename, config)
    logging.basicConfig(format='%(asctime)s:%(module)s:%(funcName)s:%(lineno)d:%(levelname)s:%(message)s',
                        datefmt='%d/%m/%Y %H:%M:%S', filename=logfilename, level=logging.DEBUG)
    logging.info('Start Application')
    scan_for_files(config)
    logging.info('Call read_metadata module')
    # Mod.read_metadata('C:/Projects/Vo/MOW Dataroom/OpenData/od_xml.xml')
    logging.info('FTP Server Handling')
    # Mr.load_file('C:/Projects/Vo/MOW Dataroom/OpenData/cijfers_11.xml')
    logging.info('End Application')


if __name__ == '__main__':
    main()
