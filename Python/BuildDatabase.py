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
    (module, fileext) = os.path.splitext(filename)
    return module


def get_inifile():
    # Use Project Name as ini file.
    projectname = 'mowdr'
    configfile = "properties/" + projectname + ".ini"
    ini_config = configparser.ConfigParser()
    try:
        ini_config.read_file(open(configfile))
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Read Inifile not successful: %s (%s)"
        print(log_msg % (e, ec))
        sys.exit(1)
    return ini_config


def get_logfilename():
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
    logfile = logdir + "/" + modulename + "_" + computername + \
        "_" + currdate + ".log"
    return logfile


def connect2db():
    try:
        db_conn = sqlite3.connect(db)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Error during connect to database: %s %s"
        logging.error(log_msg, e, ec)
        return
    else:
        return db_conn


def create_db():
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


def remove_tables():
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


def populate_attribs_main():
    """
    This procedure will populate table attribute_action with the attributes that come from Dataroom
    and need to go to Dataset Metadata screen, Main.
    :return:
    """
    attrib_od_fields = {
        'Title': 'Title',
        'notes': 'notes',
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


def populate_attribs_extra():
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


def populate_attribs_ckan():
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
            "VALUES (?, ?, 'Main', 'Dataset', 'Dataset', ?)"
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


def populate_attribs_mv():
    """
    This procedure will populate table attribute_action with the attributes that come from Mobiel Vlaanderen
    platform.
    :return:
    """
    attrib_od_fields = {
        'url_cijfers': 'url',
        'url_commentaar': 'url',
    }
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES (?, ?, 'Resource', 'Repository', ?, ?)"
    for attribute, od_field in attrib_od_fields.items():
        if 'cijfers' in attribute:
            target = 'CijfersResource'
        else:
            target = 'CommentaarResource'
        try:
            conn.execute(query, (attribute, od_field, target, now,))
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Error during query execution: %s %s"
            logging.error(log_msg, e, ec)
            return
    conn.commit()


def populate_attribs_resource():
    """
    This procedure will populate table attribute_action with the attributes that need to go to cijfers/commentaar
    Resources.
    :return:
    """
    attrib_od_fields = {
        'format_cijfers': 'format',
        'name_cijfers': 'name',
        'description_cijfers': 'description',
        'id_cijfers': 'id',
        'format_commentaar': 'format',
        'name_commentaar': 'name',
        'description_commentaar': 'description',
        'id_commentaar': 'id',
    }
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES (?, ?, 'Resource', 'Dataroom', ?, ?)"
    for attribute, od_field in attrib_od_fields.items():
        if 'cijfers' in attribute:
            target = 'CijfersResource'
        else:
            target = 'CommentaarResource'
        try:
            conn.execute(query, (attribute, od_field, target, now,))
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Error during query execution: %s %s"
            logging.error(log_msg, e, ec)
            return
    conn.commit()


# Get ini-file first.
modulename = get_modulename()
config = get_inifile()
# Now configure logfile
logfilename = get_logfilename()
logging.basicConfig(format='%(asctime)s:%(module)s:%(funcName)s:%(lineno)d:%(levelname)s:%(message)s',
                    datefmt='%d/%m/%Y %H:%M:%S', filename=logfilename, level=logging.DEBUG)
logging.info('Start Application')
logging.info('Get Database connection')
db = config['Main']['db']
conn = connect2db()
logging.info('Remove existing tables')
remove_tables()
logging.info('Create the tables')
create_db()
logging.info('Add Main Attributes')
populate_attribs_main()
logging.info('Add Extra Attributes')
populate_attribs_extra()
logging.info('Add ckan Attributes')
populate_attribs_ckan()
logging.info('Add FTP (mobiel vlaanderen) Attributes')
populate_attribs_mv()
logging.info('Add Cijfer/Commentaar Resource Attributes')
populate_attribs_resource()
conn.close()
logging.info('End Application')

