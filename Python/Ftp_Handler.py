#!/opt/csw/bin/python3

import logging
import os
import re
import sys
from ftplib import FTP


class Ftp_Handler:

    """
    This class consolidates the FTP functions. On initialization the FTP Connection object is created
    in the directory that the configuration file specifies.
    Note that there is no FTP close for now. Not sure if it is required?
    """

    def __init__(self, config_hdl):
        self.ftp_hdl = self._ftp_connection(config_hdl)
        return

    def _ftp_connection(self, config_hdl):
        """
        This procedure establishes an FTP connection to the FTP Server. The FTP connection points to the directory
        specified in the config file.
        On server uv162942 FTP login needs to be in two steps. First connect to the FTP Server, then login
        to the FTP server.
        :return: ftp object.
        """
        # TODO proper error handling: if FTP connection fails, FTP is NoType at this moment and will fail at ftp.close()
        log_msg = "Trying to establish FTP Connection"
        logging.debug(log_msg)
        host = config_hdl['FTPServer']['host']
        user = config_hdl['FTPServer']['user']
        passwd = config_hdl['FTPServer']['passwd']
        ftp = FTP()
        # First connect to the FTP Server
        try:
            log_msg = "Connect to FTP Server"
            logging.debug(log_msg)
            ftp.connect(host=host, timeout=10)
        except:
            ec = sys.exc_info()[0]
            e = sys.exc_info()[1]
            log_msg = "Error during connect to FTP Server: %s %s"
            logging.critical(log_msg, e, ec)
            sys.exit('ftp_connection failed')
        # Then login to FTP Server
        try:
            log_msg = "Login at FTP Server"
            logging.debug(log_msg)
            ftp.login(user=user, passwd=passwd)
        except:
            ec = sys.exc_info()[0]
            e = sys.exc_info()[1]
            log_msg = "Error during FTP login: %s %s \n\n"
            logging.critical(log_msg, e, ec)
            sys.exit()
        # Connected to FTP Server, now change to directory
        ftpdir = config_hdl['FTPServer']['dir']
        try:
            ftp.cwd(ftpdir)
        except:
            ec = sys.exc_info()[0]
            e = sys.exc_info()[1]
            log_msg = "Error during cwd to FTP Server: %s %s"
            logging.critical(log_msg, e, ec)
            sys.exit('ftp_cwd failed')
        return ftp

    def load_file(self, file=None):
        """
        Load file on mobielvlaanderen.be. If file exists already, then overwrite.
        :param file: Filename (including path) of the file to be loaded.
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
            self.ftp_hdl.storbinary(stor_cmd, f)
        except:
            e = sys.exc_info()[0]
            log_msg = "Error loading file: %s"
            logging.critical(log_msg, e)
            return
        log_msg = "Looks like file %s is moved to FTP Server, close file now."
        logging.debug(log_msg, file)
        f.close()
        return

    def remove_file(self, file=None):
        """
        Remove file on mobielvlaanderen.be. Remove 'empty' identifier if it is still in the filename.
        :param file: Filename of the file to be removed. Path can be part of the filename.
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
            self.ftp_hdl.delete(filename)
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Error removing file: %s %s"
            logging.error(log_msg, e, ec)
        else:
            log_msg = "Looks like file %s is removed from FTP Server"
            logging.debug(log_msg, filename)
        return
