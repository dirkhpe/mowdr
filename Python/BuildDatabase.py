__author__ = 'Dirk Vermeylen'

"""
This script will rebuild the database from scratch. It should run only once during production
and many times during development.
"""

import configparser
import datetime
import logging
import os
import sqlite3
import sys
from time import strftime

now = strftime("%H:%M:%S %d-%m-%Y")


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


def connect2db(db=None):
    try:
        conn = sqlite3.connect(db)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Error during connect to database: %s %s"
        logging.error(log_msg, e, ec)
        return
    else:
        return conn


def create_db(conn):
    # Create table
    query = 'CREATE TABLE attribute_action ' \
            '(id integer primary key, attribute text, od_field text, ' \
            'action text, source text, target text, created text)'
    try:
        conn.execute(query)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Error during query execution - Attribute_action: %s %s"
        logging.error(log_msg, e, ec)
        return
    query = 'CREATE TABLE indicators ' \
            '(id integer primary key, indicator_id integer, attribute text, ' \
            'value text, created text, ' \
            'FOREIGN KEY(attribute) REFERENCES attribute_action(attribute))'
    try:
        conn.execute(query)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Error during query execution - Indicators: %s %s"
        logging.error(log_msg, e, ec)
        return
    return True


def remove_tables(conn):
    query = 'DROP TABLE IF EXISTS indicators'
    try:
        conn.execute(query)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Error during query execution: %s %s"
        logging.error(log_msg, e, ec)
        return
    query = 'DROP TABLE IF EXISTS attribute_action'
    try:
        conn.execute(query)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Error during query execution: %s %s"
        logging.error(log_msg, e, ec)
        return


def populate_attribs_main(conn):
    """
    This procedure will populate table attribute_action with the attributes that come from Dataroom
    and need to go to Dataset Metadata screen, Main.
    :return:
    """
    attrib_od_fields = {
        'Title': 'Title',
    }
    # cur = conn.cursor()
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES (?, ?, 'Main', 'Dataroom', 'Dataset', ?)"
    for attribute, od_field in attrib_od_fields.items():
        try:
            conn.execute(query, (attribute, od_field, now,))
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Error during query execution: %s %s"
            logging.error(log_msg, e, ec)
            return
    conn.commit()
    return


def populate_attribs_extra(conn):
    """
    This procedure will populate table attribute_action with the attributes that come from Dataroom
    and need to go to Dataset Metadata screen, section 'Extra Informatie'.
    :return:
    """
    attrib_od_fields = {
        'AantalPercentage': 'Aantal of Percentage',
        'Berekeningswijze': 'Berekeningswijze',
        'CijfersBijgewerkt': 'Cijfers Bijgewerkt',
        'Definitie': 'Definitie',
        'Dimensies': 'Dimensies',
        'DoelMeting': 'Doel Meting',
        'Meeteenheid': 'Meeteenheid',
        'Meetfrequentie': 'Meetfrequentie',
        'Meettechniek': 'Meettechniek',
        'Tijdsvenster': 'Tijdsvenster',
        'TypeIndicator': 'Type Indicator',
    }
    # cur = conn.cursor()
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES (?, ?, 'Extra', 'Dataroom', 'Dataset', ?)"
    for attribute, od_field in attrib_od_fields.items():
        try:
            conn.execute(query, (attribute, od_field, now,))
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Error during query execution: %s %s"
            logging.error(log_msg, e, ec)
            return
    conn.commit()


def populate_attribs_ckan(conn):
    """
    This procedure will populate table attribute_action with the attributes that come from ckan Open Data
    platform.
    :return:
    """
    attrib_od_fields = {
        'id': 'id',
        'revision_id': 'revision_id',
        'name': 'name',
    }
    # cur = conn.cursor()
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES (?, ?, 'DatasetIdentification', 'Dataset', 'Dataset', ?)"
    for attribute, od_field in attrib_od_fields.items():
        try:
            conn.execute(query, (attribute, od_field, now,))
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Error during query execution: %s %s"
            logging.error(log_msg, e, ec)
            return
    conn.commit()


def populate_attribs_mv(conn):
    """
    This procedure will populate table attribute_action with the attributes that come from Mobiel Vlaanderen
    platform.
    :return:
    """
    attrib_od_fields = {
        'url_cijfers': 'url_cijfers',
        'url_commentaar': 'url_commentaar',
    }
    # cur = conn.cursor()
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES (?, ?, 'Repository', 'Repository', 'Dataset', ?)"
    for attribute, od_field in attrib_od_fields.items():
        try:
            conn.execute(query, (attribute, od_field, now,))
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Error during query execution: %s %s"
            logging.error(log_msg, e, ec)
            return
    conn.commit()


def main():
    # Get ini-file first.
    modulename = get_modulename()
    config = get_inifile()
    # Now configure logfile
    logfilename = get_logfilename(modulename, config)
    logging.basicConfig(format='%(asctime)s:%(module)s:%(funcName)s:%(lineno)d:%(levelname)s:%(message)s',
                        datefmt='%d/%m/%Y %H:%M:%S', filename=logfilename, level=logging.DEBUG)
    logging.info('Start Application')
    logging.info('Get Database connection')
    db = config['Main']['db']
    conn = connect2db(db)
    logging.info('Remove existing tables')
    remove_tables(conn)
    logging.info('Create the tables')
    create_db(conn)
    logging.info('Add Main Attributes')
    populate_attribs_main(conn)
    logging.info('Add Extra Attributes')
    populate_attribs_extra(conn)
    logging.info('Add ckan Attributes')
    populate_attribs_ckan(conn)
    logging.info('Add FTP (mobiel vlaanderen) Attributes')
    populate_attribs_mv(conn)
    conn.close()
    logging.info('End Application')

if __name__ == '__main__':
    main()
