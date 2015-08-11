__author__ = 'Dirk Vermeylen'

import sqlite3
import sys
from time import strftime

now = strftime("%H:%M:%S %d-%m-%Y")

def connect2db(db=None):
    try:
        conn = sqlite3.connect(db)
    except:
        e = sys.exc_info()[0]
        print("Error during connect to database: %s" % e)
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
        e = sys.exc_info()[0]
        print("Error during query execution - Attribute_action %s" % e)
        return
    query = 'CREATE TABLE indicators ' \
            '(id integer primary key, indicator_id integer, attribute text, ' \
            'value text, created text, ' \
            'FOREIGN KEY(attribute) REFERENCES attribute_action(attribute))'
    try:
        conn.execute(query)
    except:
        e = sys.exc_info()[0]
        print("Error during query execution - Indicators %s" % e)
        return
    return True


def remove_tables():
    conn = sqlite3.connect('dataroom_od.db')
    query = 'DROP TABLE IF EXISTS indicators'
    try:
        conn.execute(query)
    except:
        e = sys.exc_info()[0]
        print("Error during query execution %s" % e)
        return
    query = 'DROP TABLE IF EXISTS attribute_action'
    try:
        conn.execute(query)
    except:
        e = sys.exc_info()[0]
        print("Error during query execution %s" % e)
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
            e = sys.exc_info()[0]
            print("Error during query execution %s" % e)
            print(query)
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
            e = sys.exc_info()[0]
            print("Error during query execution %s" % e)
            print(query)
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
            e = sys.exc_info()[0]
            print("Error during query execution %s" % e)
            print(query)
            return
    conn.commit()
