"""
ManageOpenData Class.

This module consolidates the functions for managing the Open Data
for the MOW Dataroom application.
"""

__author__ = 'Dirk Vermeylen'

import ckanapi
import logging
import re
import sqlite3
import sys
import xml.etree.ElementTree as Et
from time import strftime

now = strftime("%H:%M:%S %d-%m-%Y")
conn = sqlite3.connect('dataroom_od.db')
cur = conn.cursor()


def connect2ckan(test=True):
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
    Read the file with metadata and add or replace the information to table indicators.
    Call function to create dataset if this is a new dataset.
    :param metafile: pointer to the file with metadata.
    :return:
    """
    log_msg = "In read_metadata for file " + metafile
    logging.info(log_msg)
    try:
        tree = Et.parse(metafile)
    except:  # catch all errors for now, try to be more specific in the future.
        e = sys.exc_info()[0]
        log_msg = "Error during parsing metafile xml: %s" % e
        logging.critical(log_msg)
        return
    root = tree.getroot()
    try:
        indic_id = int(root.find('id').text)
    except:
        e = sys.exc_info()[0]
        log_msg = "Error during parsing metafile xml: %s" % e
        logging.critical(log_msg)
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
            log_msg = "Found Dataroom Attribute **" + child.tag + "** not required for Open Data Dataset"
            logging.warning(log_msg)
    conn.commit()
    # Now check if dataset exist already: is there an ID available in the indicators table for this indicator.
    query = "SELECT value FROM indicators WHERE attribute = 'ID' and indicator_id = ?"
    cur.execute(query, (indic_id,))
    values_lst = cur.fetchall()
    # I want to have 0 or 1 rows in the list
    if len(values_lst) == 0:
        log_msg = "Open Data dataset is not registered for Indicator ID %s, call to register"
        logging.info(log_msg, indic_id)
        create_package(indic_id=indic_id)
    elif len(values_lst) == 1:
        log_msg = "Open Data dataset exists for Indicator ID %s, no further action"
        logging.info(log_msg, indic_id)
    else:
        log_msg = "Multiple Open Data dataset links found for Indicator ID %s, please review"
        logging.warning(log_msg, indic_id)
    return True


def create_package(indic_id=0):
    log_msg = "In create_package for Indicator %s"
    logging.info(log_msg, indic_id)
     # Get mandatory items for the package: Title, name and owner_org
    query = "SELECT value FROM indicators WHERE indicator_id = ? AND attribute = 'Title'"
    cur.execute(query, (indic_id,))
    title_list = cur.fetchall()
    # I need to have exact 1 title
    if len(title_list) == 0:
        log_msg = "No Title defined for Indicator ID %s"
        logging.error(log_msg, indic_id)
        return
    elif len(title_list) == 1:
        title = title_list[0][0]
    else:
        log_msg = "Multiple titles (?) defined for Indicator ID %s"
        logging.error(log_msg, len(title_list), indic_id)
        return
    # OK, 1 title found. Convert it to a name
    name = 'dmow-ind' + str(indic_id).zfill(3) + '-' + title
    name = re.sub('[^0-9a-zA-Z_\-]', '_', name).lower()
    logging.info("Name: %s", name)
    my_param = {
        'name': name,
        'title': title,
        'owner_org': 'testbeorg',
    }
    logging.debug("Parameters: %s", my_param)
    # Get OD_Connection
    # od_conn = connect2ckan()
    beta_ckan = 'http://beta.ckan.org/'
    beta_api = '342eb47e-d72d-4b45-bd8a-4fac7bcf59b7'
    try:
        od_conn = ckanapi.RemoteCKAN(beta_ckan, apikey=beta_api)
    except:
        log_msg = "Connect to RemoteCKAN not successful"
        logging.error(log_msg)
        return
    log_msg = "Connect to ckan did not report any errors, connection type: %s"
    logging.info(log_msg, type(od_conn))
    try:
        pkg = od_conn.action.package_create(**my_param)
    except ckanapi.NotAuthorized:
        log_msg = 'user unauthorized or accessing a deleted item'
        logging.warning(log_msg)
    except ckanapi.NotFound:
        log_msg = 'name/id not found'
        logging.warning(log_msg)
    except ckanapi.SearchError:
        log_msg = 'There is a SearchError'
        logging.warning(log_msg)
    except ckanapi.SearchIndexError:
        log_msg = 'There is a SearchIndexError'
        logging.warning(log_msg)
    except ckanapi.SearchQueryError:
        log_msg = 'There is SearchQueryError'
        logging.warning(log_msg)
    except ckanapi.ServerIncompatibleError:
        log_msg = 'There is a ServerIncompatibleError'
        logging.warning(log_msg)
    except ckanapi.ValidationError:
        log_msg = 'Validation errors'
        logging.warning(log_msg)
    except ckanapi.CKANAPIError:
        log_msg = 'CatchAll - Incorrect use of ckanapi or unable to parse response'
        logging.warning(log_msg)
    else:
        # Collect Package information and set it in the database.
        try:
            val_id = pkg['id']
        except:
            log_msg = "Create package with no errors, but no package ID found..."
            logging.error(log_msg)
            return
        else:
            # Store package ID in indicators table
            query = "INSERT INTO indicators (indicator_id, attribute, value, created) " \
                    "VALUES (?, 'id', ?, ?)"
            try:
                cur.execute(query, (indic_id, val_id, now))
            except:
                log_msg = "Insert query failed **%s**, indic_id: %s, Value_id: %s"
                logging.error(log_msg, query, indic_id, val_id)
                return
            conn.commit()
        log_msg = 'Looks like I have my package...'
        logging.info(log_msg)
    log_msg = "End of create_package processing for Indicator %s"
    logging.info(log_msg, indic_id)


