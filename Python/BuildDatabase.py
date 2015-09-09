__author__ = 'Dirk Vermeylen'

"""
This script will rebuild the database from scratch. It should run only once during production
and many times during development.
"""

import logging
import sqlite3
import sys
from lib import my_env
from time import strftime

now = strftime("%H:%M:%S %d-%m-%Y")


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
            '(id integer primary key, attribute text unique, od_field text, ' \
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
        'author': 'author',
        'author_email': 'author_email',
        'maintainer': 'maintainer_email',
        'language': 'language',
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
    Note that it is mandatory that attribute name is unique.
    :return:
    """
    attrib_od_fields = {
        'AantalPercentage': 'Aantal of Percentage',
        'Berekeningswijze': 'Berekeningswijze',
        'Definitie': 'Definitie',
        'Dimensies': 'Dimensies',
        'DoelMeting': 'Doel Meting',
        'Meeteenheid': 'Meeteenheid',
        'Meetfrequentie': 'Meetfrequentie',
        'Meettechniek': 'Meettechniek',
        'Tijdsvenster': 'Tijdsvenster',
        'TypeIndicator': 'Type Indicator',
        'FicheBijgewerkt': 'Gegevens Bijgewerkt',
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
        'license_id': 'license_id'
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


def populate_attribs_od_res():
    """
    This procedure will populate table attribute_action with the attributes that come from Dataset to populate Resource.
    :return:
    """
    attrib_od_fields = {
        'id_cijfers': 'id',
        'id_commentaar': 'id',
    }
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES (?, ?, 'Resource', 'Dataset', ?, ?)"
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


def populate_attribs_mv():
    """
    This procedure will populate table attribute_action with the attributes that come from Mobiel Vlaanderen
    platform.
    :return:
    """
    attrib_od_fields = {
        'url_cijfers': 'url',
        'url_commentaar': 'url',
        'size_cijfers': 'Aantal Bytes',
        'size_commentaar': 'Aantal Bytes',
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
        'tdt_cijfers': 'enable-tdt',
        'format_commentaar': 'format',
        'name_commentaar': 'name',
        'description_commentaar': 'description',
        'tdt_commentaar': 'enable_tdt',
        'CijfersBijgewerkt': 'Cijfers Bijgewerkt',
        'CommBijgewerkt': 'Commentaar Bijgewerkt',

    }
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES (?, ?, 'Resource', 'Dataroom', ?, ?)"
    for attribute, od_field in attrib_od_fields.items():
        if 'cijfers' in attribute.lower():
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
projectname = 'mowdr'
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname)
# Now configure logfile
my_env.init_logfile(config, modulename)
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
logging.info('Add Cijfer/Commentaar Resource Attributes from dataset')
populate_attribs_od_res()
conn.close()
logging.info('End Application')
