__author__ = 'Dirk Vermeylen'

import ckanapi
import sys
import xml.etree.ElementTree as Et
import sqlite3
from time import strftime

now = strftime("%H:%M:%S %d-%m-%Y")
conn = sqlite3.connect('dataroom_od.db')
cur = conn.cursor()

# class ManageOpenData:
"""
ManageOpenData Class.

This module consolidates the functions for managing the Open Data
for the MOW Dataroom application.
"""


def connect(test=True):
    """
    Initialization will set default parameters
    and connect to the Open Data Platform.
    Default connection is to test platform beta.ckan.org.
    If test=False is specified, then connection is to ckan-001.corve.openminds.be.
    :return:
    """
    if test:
        beta_ckan = 'http://beta.ckan.org/'
        beta_api = '342eb47e-d72d-4b45-bd8a-4fac7bcf59b7'
        od_conn = ckanapi.RemoteCKAN(beta_ckan, apikey=beta_api)
    else:
        vo_ckan = 'http://ckan-001.corve.openminds.be/'
        vo_api = '42eb6dc6-a5c5-4249-86a7-9ca2e7f0b6bb'
        od_conn = ckanapi.RemoteCKAN(vo_ckan, apikey=vo_api)
    return od_conn


def read_metadata(metafile=None):
    """
    Read the file with metadata and add the information to the table in database.
    Call function to create dataset if this is a new dataset.
    :param metafile: pointer to the file with metadata.
    :return:
    """
    try:
        tree = Et.parse(metafile)
    except:  # catch all errors for now, try to be more specific in the future.
        e = sys.exc_info()[0]
        print("Error during parsing metafile xml: %s" % e)
        return
    print("Processing File " + metafile)
    root = tree.getroot()
    try:
        indic_id = int(root.find('id').text)
    except:
        e = sys.exc_info()[0]
        print("Error during parsing metafile xml: %s" % e)
        return
    # metadata is available, get list of attributes from Dataroom Application
    # and required for Dataset Page.
    # First collect all attribute names
    query = "SELECT attribute FROM attribute_action " \
            "WHERE source = 'Dataroom' AND target = 'Dataset'"
    cur.execute(query)
    attribs = cur.fetchall()
    attrib_names = []
    for row in attribs:
        attrib_names.append(row[0])
    # Then remove information from Dataroom for Dataset for this indicator ID.
    query = "DELETE FROM indicators WHERE indicator_id = ? AND attribute = ?"
    for attrib_name in attrib_names:
        # print(attrib_name + " - Type: " + str(type(indic_id)))
        cur.execute(query, (indic_id, attrib_name))
    # And then add new information from Dataroom for Dataset for thsi indicator ID.
    query = "INSERT INTO indicators (indicator_id, attribute, value, created) VALUES (?, ?, ?, ?)"
    for child in root:
        if child.tag in attrib_names:
            cur.execute(query, (indic_id, child.tag, child.text.strip(), now))
        else:
            print("Found Dataroom Attribute **" + child.tag + "** not required for Open Data Dataset")
    conn.commit()
