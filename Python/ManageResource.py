__author__ = 'Dirk Vermeylen'

"""
This script consolidates the FTP handling of the resources.
Options: Load, to load a dataset. Remove the dataset first if it already exists.
Remove: only remove the dataset. This option is required for disabling indicators and removing all data.
"""

from ftplib import FTP
import logging
import os
import sys

host = "www.mobielvlaanderen.be"
user = "SteenhaJu"
passwd = "T-reX927501"


def get_dirlist():
    """
    Get directory list on FTP Server.
    :return:
    """
    try:
        ftp = FTP(host=host, user=user, passwd=passwd)
    except:
        e = sys.exc_info()[0]
        log_msg = "Error during connect to FTP Server %s: %s"
        logging.critical(log_msg, host, e)
        return
    try:
        dirlist = ftp.mlsd()
    except:
        e = sys.exc_info()[0]
        log_msg = "Error getting FTP Directory: %s"
        logging.critical(log_msg, e)
        ftp.close()
        return
    print("Dirlist: %s" % dirlist)
    for (f,fd) in dirlist:
        print(f + " %s" % fd)
    ftp.close()


def load_file(file=None, remove_only=False):
    """
    Load file. Remove the file first if it exists already (since it is an older version).
    If remove_only is True, then only remove the file.
    :param file: Filename of the file to be loaded.
    :param remove_only: Default: False. If True then this will remove the specified file.
    :return:
    """
    # Get Filename from file pointer
    (filepath, filename) = os.path.split(file)
    # Connect to FTP Host
    try:
        ftp = FTP(host=host, user=user, passwd=passwd)
    except:
        e = sys.exc_info()[0]
        log_msg = "Error during connect to FTP Server %s: %s"
        logging.critical(log_msg, host, e)
        return
    # Get list of current files
    try:
        dirlist = ftp.mlsd()
    except:
        e = sys.exc_info()[0]
        log_msg = "Error getting FTP Directory: %s"
        logging.critical(log_msg, e)
        ftp.close()
        return
    # Get filenames (first element in each tuple) in list
    files = [f for (f, fd) in dirlist]
    print("%s" % files)
    if filename in files:
        print("Filename %s found on FTP Server" % filename)
    else:
        print("Filename %s not found on FTP Server" % filename)
    # Load the File
    try:
        f = open(file, mode='rb')
    except:
        e = sys.exc_info()[0]
        log_msg = "Error to open file %s"
        logging.critical(log_msg, e)
        ftp.close()
        return
    stor_cmd = 'STOR ' + filename
    try:
        ftp.storbinary(stor_cmd, f)
    except:
        e = sys.exc_info()[0]
        log_msg = "Error loading file: %s"
        logging.critical(log_msg, e)
        ftp.close()
        return
    dirlist = ftp.mlsd()
    files = [f for (f, fd) in dirlist]
    print("%s" % files)
    if filename in files:
        print("Filename %s found on FTP Server" % filename)
    else:
        print("Filename %s not found on FTP Server" % filename)
    ftp.close()
