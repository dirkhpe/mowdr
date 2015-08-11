__author__ = 'Dirk Vermeylen'

import logging
import sqlite3
import sys
from time import strftime

now = strftime("%H:%M:%S %d-%m-%Y")

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


def create_db():
    conn = sqlite3.connect('dataroom_od.db')
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
    conn = sqlite3.connect('dataroom_od.db')
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
    }
    conn = sqlite3.connect('dataroom_od.db')
    # cur = conn.cursor()
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES (?, ?, 'Main', 'Dataroom', 'Dataset', ?)"
    for attribute, od_field in attrib_od_fields.items():
        try:
            conn.execute(query, (attribute,od_field, now,))
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Error during query execution: %s %s"
            logging.error(log_msg, e, ec)
            return
    conn.commit()


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
    conn = sqlite3.connect('dataroom_od.db')
    # cur = conn.cursor()
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES (?, ?, 'Extra', 'Dataroom', 'Dataset', ?)"
    for attribute, od_field in attrib_od_fields.items():
        try:
            conn.execute(query, (attribute,od_field, now,))
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
    conn = sqlite3.connect('dataroom_od.db')
    # cur = conn.cursor()
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES (?, ?, 'DatasetIdentification', 'Dataset', 'Dataset', ?)"
    for attribute, od_field in attrib_od_fields.items():
        try:
            conn.execute(query, (attribute,od_field, now,))
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
        'url_cijfers': 'url_cijfers',
        'url_commentaar': 'url_commentaar',
    }
    conn = sqlite3.connect('dataroom_od.db')
    # cur = conn.cursor()
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES (?, ?, 'Repository', 'Repository', 'Dataset', ?)"
    for attribute, od_field in attrib_od_fields.items():
        try:
            conn.execute(query, (attribute,od_field, now,))
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Error during query execution: %s %s"
            logging.error(log_msg, e, ec)
            return
    conn.commit()
