__author__ = 'vermeyle'

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


def populate_attribute_action():
    conn = sqlite3.connect('dataroom_od.db')
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES ('AantalPercentage', 'Aantal of Percentage', 'Extra', 'Dataroom', 'Dataset', ?)"
    try:
        conn.execute(query, (now,))
    except:
        e = sys.exc_info()[0]
        print("Error during query execution %s" % e)
        print(query)
        return
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES ('Berekeningswijze', 'Berekeningswijze', 'Extra', 'Dataroom', 'Dataset', ?)"
    try:
        conn.execute(query, (now,))
    except:
        e = sys.exc_info()[0]
        print("Error during query execution %s" % e)
        print(query)
        return
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES ('Berekeningswijze', 'Berekeningswijze', 'Extra', 'Dataroom', 'Dataset', ?)"
    try:
        conn.execute(query, (now,))
    except:
        e = sys.exc_info()[0]
        print("Error during query execution %s" % e)
        print(query)
        return
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES ('CijfersBijgewerkt', 'Cijfers Bijgewerkt', 'Extra', 'Dataroom', 'Dataset', ?)"
    try:
        conn.execute(query, (now,))
    except:
        e = sys.exc_info()[0]
        print("Error during query execution %s" % e)
        print(query)
        return
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES ('Definitie', 'Definitie', 'Extra', 'Dataroom', 'Dataset', ?)"
    try:
        conn.execute(query, (now,))
    except:
        e = sys.exc_info()[0]
        print("Error during query execution %s" % e)
        print(query)
        return
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES ('Dimensies', 'Dimensies', 'Extra', 'Dataroom', 'Dataset', ?)"
    try:
        conn.execute(query, (now,))
    except:
        e = sys.exc_info()[0]
        print("Error during query execution %s" % e)
        print(query)
        return
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES ('DoelMeting', 'Doel Meting', 'Extra', 'Dataroom', 'Dataset', ?)"
    try:
        conn.execute(query, (now,))
    except:
        e = sys.exc_info()[0]
        print("Error during query execution %s" % e)
        print(query)
        return
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES ('Meeteenheid', 'Meeteenheid', 'Extra', 'Dataroom', 'Dataset', ?)"
    try:
        conn.execute(query, (now,))
    except:
        e = sys.exc_info()[0]
        print("Error during query execution %s" % e)
        print(query)
        return
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES ('Meetfrequentie', 'Meetfrequentie', 'Extra', 'Dataroom', 'Dataset', ?)"
    try:
        conn.execute(query, (now,))
    except:
        e = sys.exc_info()[0]
        print("Error during query execution %s" % e)
        print(query)
        return
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES ('Meettechniek', 'Meettechniek', 'Extra', 'Dataroom', 'Dataset', ?)"
    try:
        conn.execute(query, (now,))
    except:
        e = sys.exc_info()[0]
        print("Error during query execution %s" % e)
        print(query)
        return
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES ('Tijdsvenster', 'Tijdsvenster', 'Extra', 'Dataroom', 'Dataset', ?)"
    try:
        conn.execute(query, (now,))
    except:
        e = sys.exc_info()[0]
        print("Error during query execution %s" % e)
        print(query)
        return
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES ('TypeIndicator', 'Type Indicator', 'Extra', 'Dataroom', 'Dataset', ?)"
    try:
        conn.execute(query, (now,))
    except:
        e = sys.exc_info()[0]
        print("Error during query execution %s" % e)
        print(query)
        return
    query = "INSERT INTO attribute_action (attribute, od_field, action, source, target, created) " \
            "VALUES ('Title', 'Title', 'Extra', 'Dataroom', 'Dataset', ?)"
    try:
        conn.execute(query, (now,))
    except:
        e = sys.exc_info()[0]
        print("Error during query execution %s" % e)
        print(query)
        return
    try:
        conn.commit()
    except:
        e = sys.exc_info()[0]
        print("Error during commit %s" % e)
        print(query)
        return
    conn.close()
