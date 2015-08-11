__author__ = 'Dirk Vermeylen'

"""
This script will rebuild the database from scratch. It should run only once during production
and many times during development.
"""

import logging
import os
import datetime
import sys
import ManageDB as Mdb


def get_logfilename():
    """
    Temporary function to define Logfile Name.
    :return:
    """
    logdir = 'c:/temp/log'
    # Current Date for filename
    currdate = datetime.date.today().strftime("%Y%m%d")
    # Extract calling application name
    (filepath, filename) = os.path.split(sys.argv[0])
    (modulename, fileext) = os.path.splitext(filename)
    # Extract Computername
    computername = os.environ.get("COMPUTERNAME")
    # Define logfileName
    logfilename = logdir + "/" + modulename + "_" + computername + \
        "_" + currdate + ".log"
    return logfilename


def main():
    logfilename = get_logfilename()
    logging.basicConfig(format='%(asctime)s:%(levelname)s:%(message)s', datefmt='%d/%m/%Y %H:%M:%S',
                        filename=logfilename, level=logging.INFO)
    logging.info('Start Application')
    logging.info('Remove existing tables')
    Mdb.remove_tables()
    logging.info('Create the tables')
    Mdb.create_db()
    logging.info('Add Main Attributes')
    Mdb.populate_attribs_main()
    logging.info('Add Extra Attributes')
    Mdb.populate_attribs_extra()
    logging.info('Add ckan Attributes')
    Mdb.populate_attribs_ckan()
    logging.info('End Application')

if __name__ == '__main__':
    main()
