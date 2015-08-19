__author__ = 'Dirk Vermeylen'

"""
This is the main application to handle files from Dataroom and
process them for loading on the Open Data Platform.
"""

import ckanapi
import configparser
import datetime
from ftplib import FTP
import logging
import os
import re
import sqlite3
import sys
from time import strftime
import xml.etree.ElementTree as Et


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
    db = config['Main']['db']
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


def ftp_connection():
    """
    This procedure establishes an FTP connection to the FTP Server.
    :return: ftp object.
    """
    log_msg = "Trying to establish FTP Connection"
    logging.debug(log_msg)
    host = config['FTPServer']['host']
    user = config['FTPServer']['user']
    passwd = config['FTPServer']['passwd']
    try:
        ftp = FTP(host=host, user=user, passwd=passwd)
    except:
        ec = sys.exc_info()[0]
        e = sys.exc_info()[1]
        log_msg = "Error during connect to FTP Server: %s %s"
        logging.critical(log_msg, e, ec)
        return
    return ftp


def load_file(ftp, file=None):
    """
    Load file on mobielvlaanderen.be. If file exists already, then overwrite.
    :param file: Filename of the file to be loaded.
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
        ftp.storbinary(stor_cmd, f)
    except:
        e = sys.exc_info()[0]
        log_msg = "Error loading file: %s"
        logging.critical(log_msg, e)
        return
    log_msg = "Looks like file %s is moved to FTP Server, close file now."
    logging.debug(log_msg, file)
    f.close()
    return


def remove_file(ckan_conn, ftp, file=None):
    """
    Remove file on mobielvlaanderen.be.
    :param file: Filename of the file to be loaded.
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
        ftp.delete(filename)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Error removing file: %s %s"
        logging.error(log_msg, e, ec)
    else:
        log_msg = "Looks like file %s is removed from FTP Server"
        logging.debug(log_msg, file)
    log_msg = "Check Open Data Resource for %s"
    logging.debug(log_msg, filename)
    indic_id = indic_from_file(filename)
    res_type = type_from_file(filename)
    remove_resource(ckan_conn, indic_id, res_type)
    return


def move_file(file2move, sourcedir, targetdir):
    """
    This function will move a file from source dir to target dir.
    It will check if the file exists on target dir. If so, remove file from target dir.
    Then move file from source dir. Assumption: file must exist on sourcedir.
    :param file2move: Filename of the file that needs to be moved
    :param sourcedir: Source Directory where the file is now.
    :param targetdir: Target Directory where the file needs to go to.
    :return:
    """
    if file2move in [file for file in os.listdir(targetdir)]:
        log_msg = "File %s exists in targetdir %s, remove first"
        logging.debug(log_msg, file2move, targetdir)
        os.remove(os.path.join(targetdir, file2move))
    log_msg = "OK, File %s does not exists in targetdir %s now."
    logging.debug(log_msg, file2move, targetdir)
    os.rename(os.path.join(sourcedir, file2move), os.path.join(targetdir, file2move))
    return


def indic_from_file(filename):
    """
    This procedure will extract the indicator ID from the filename.
    The indicator number is between _ and first . (empty. can be there as second dot.)
    :param filename:
    :return: indic_id (numeric)
    """
    log_msg = "Getting indicator ID from %s"
    logging.debug(log_msg, filename)
    parts = filename.split('_')
    indic_array = parts[1].split('.')
    indic_id = int(indic_array[0])
    log_msg = "Indicator ID: %s"
    logging.debug(log_msg, indic_id)
    return indic_id


def type_from_file(filename):
    """
    This procedure will extract the Type from the filename.
    The resource type is before first _ .
    :param filename:
    :return: resource type
    """
    log_msg = "Getting Resource type from %s"
    logging.debug(log_msg, filename)
    parts = filename.split('_')
    res_type = parts[0]
    log_msg = "Resource Type: %s"
    logging.debug(log_msg, res_type)
    return res_type


def url_in_db(file):
    """
    Update table indicators with url information. If filename is empty, then remove entry from table.
    Else add URL to the table.
    :param file:
    :return:
    """
    logging.debug('Add/Remove file %s to indicators table.', file)
    indic_id = indic_from_file(file)
    now = strftime("%H:%M:%S %d-%m-%Y")
    if 'cijfers' in file:
        attribute = 'url_cijfers'
    else:
        attribute = 'url_commentaar'
    # Always prepare and run query for delete. Then no INSERT/UPDATE logic is required.
    query = "DELETE FROM indicators WHERE indicator_id = ? AND attribute = ?"
    conn.execute(query, (indic_id, attribute))
    if 'empty' not in file:
        ftp_home = config['FTPServer']['ftp_home']
        url = ftp_home + '/' + file
        query = "INSERT INTO indicators (indicator_id, attribute, value, created)" \
                "VALUES (?, ?, ?, ?)"
        conn.execute(query, (indic_id, attribute, url, now))
    conn.commit()
    return


def size_of_file(handledir, file):
    """
    If file does not contain empty, then calculate Size of the file.
    :param file:
    :return:
    """
    logging.debug('Add/Remove filesize %s to indicators table.', file)
    indic_id = indic_from_file(file)
    now = strftime("%H:%M:%S %d-%m-%Y")
    if 'cijfers' in file:
        attribute = 'size_cijfers'
    else:
        attribute = 'size_commentaar'
    # Always prepare and run query for delete. Then no INSERT/UPDATE logic is required.
    query = "DELETE FROM indicators WHERE indicator_id = ? AND attribute = ?"
    conn.execute(query, (indic_id, attribute))
    if 'empty' not in file:
        filename = os.path.join(handledir, file)
        size = os.path.getsize(filename)
        query = "INSERT INTO indicators (indicator_id, attribute, value, created)" \
                "VALUES (?, ?, ?, ?)"
        conn.execute(query, (indic_id, attribute, size, now))
    conn.commit()
    return


def load_metadata(metafile, indic_id, ckan_conn):
    """
    Read the file with metadata and add or replace the information to table indicators. This procedure will populate
    all fields that come from the 'Dataroom'.
    Call function to create dataset if this is a new dataset.
    Cognos Add / Remove needs to be added here.
    :param metafile: pointer to the file with metadata.
    :return:
    """
    log_msg = "In load_metadata for file " + metafile
    logging.debug(log_msg)
    now = strftime("%H:%M:%S %d-%m-%Y")
    try:
        tree = Et.parse(metafile)
    except:  # catch all errors for now, try to be more specific in the future.
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Error during parsing metafile xml: %s %s"
        logging.critical(log_msg, e, ec)
        return
    root = tree.getroot()
    # metadata is available, get list of attributes from Dataroom Application
    # and required for Dataset Page.
    # First collect all attribute names
    query = "SELECT attribute FROM attribute_action WHERE source = 'Dataroom'"
    # cur = conn.cursor()
    cur.execute(query)
    attribs = cur.fetchall()
    attrib_names = []
    for row in attribs:
        attrib_names.append(row[0])
    # Then remove information from Dataroom for Dataset for this indicator ID.
    query = "DELETE FROM indicators WHERE indicator_id = ? AND attribute = ?"
    for attrib_name in attrib_names:
        cur.execute(query, (indic_id, attrib_name))
    # And then add new information from Dataroom for Dataset for this indicator ID.
    query = "INSERT INTO indicators (indicator_id, attribute, value, created) VALUES (?, ?, ?, ?)"
    for child in root:
        if child.tag in attrib_names:
            if child.text:
                child_text = child.text.strip()
            else:
                child_text = '(niet ingevuld)'
            cur.execute(query, (indic_id, child.tag, child_text, now))
            # Add 'notes' field (copy of definitie)
            if child.tag.lower() == 'definitie':
                cur.execute(query, (indic_id, 'notes', child_text, now))
            if child.tag.lower() == 'title':
                # Set Title for cijfers, commentaar and Cognos report (to do).
                name_cijfers = child_text + " - cijfers"
                cur.execute(query, (indic_id, 'name_cijfers', name_cijfers, now))
                name_commentaar = child_text + " - commentaar"
                cur.execute(query, (indic_id, 'name_commentaar', name_commentaar, now))
        elif child.tag != 'id':
            log_msg = "Found Dataroom Attribute **" + child.tag + "** not required for Open Data Dataset"
            logging.warning(log_msg)
    # Add cijfers / commentaar fields format, description
    desc_cijfers = "Eventuele opmerkingen bij de cijferrecords voor een bepaalde periode (cfr. meetfrequentie)" \
                   " zijn terug te vinden in de commentaar file."
    cur.execute(query, (indic_id, 'description_cijfers', desc_cijfers, now))
    desc_commentaar = "Opmerkingen horend bij de cijferrecords voor een bepaalde periode (cfr. meetfrequentie)."
    cur.execute(query, (indic_id, 'description_commentaar', desc_commentaar, now))
    format_cijfers = "XML"
    cur.execute(query, (indic_id, 'format_cijfers', format_cijfers, now))
    format_commentaar = "XML"
    cur.execute(query, (indic_id, 'format_commentaar', format_commentaar, now))
    tdt_cijfers = "on"
    cur.execute(query, (indic_id, 'tdt_cijfers', tdt_cijfers, now))
    tdt_commentaar = "on"
    cur.execute(query, (indic_id, 'tdt_commentaar', tdt_commentaar, now))
    # Also add author / author_email and beheerder / beheerder email
    author_name = "Bart Van Herbruggen, Beleidsdomein Mobiliteit en Openbare Werken"
    author_email = "bart.vanherbruggen@mow.vlaanderen.be"
    cur.execute(query, (indic_id, 'author', author_name, now))
    cur.execute(query, (indic_id, 'author_email', author_email, now))
    cur.execute(query, (indic_id, 'maintainer', author_name, now))
    cur.execute(query, (indic_id, 'maintainer_email', author_email, now))
    # And add a field for the language
    cur.execute(query, (indic_id, 'language', 'nl', now))
    conn.commit()
    # Now check if dataset exist already: is there an ID available in the indicators table for this indicator.
    query = "SELECT value FROM indicators WHERE attribute = 'id' and indicator_id = ?"
    cur.execute(query, (indic_id,))
    values_lst = cur.fetchall()
    upd_pkg = "OK"
    # I want to have 0 or 1 rows in the list
    if len(values_lst) == 0:
        log_msg = "Open Data dataset is not registered for Indicator ID %s, call to register"
        logging.info(log_msg, indic_id)
        if not create_package(indic_id, ckan_conn):
            upd_pkg = "NOK"
    elif len(values_lst) == 1:
        log_msg = "Open Data dataset exists for Indicator ID %s, no further action"
        logging.info(log_msg, indic_id)
    else:
        log_msg = "Multiple Open Data dataset links found for Indicator ID %s, please review"
        logging.warning(log_msg, indic_id)
    if upd_pkg == "OK":
        update_package(indic_id, ckan_conn)
    return True


def create_package(indic_id, ckan_conn):
    log_msg = "In create_package for Indicator %s"
    logging.info(log_msg, indic_id)
    # Get mandatory items for the package: Title, name and owner_org
    now = strftime("%H:%M:%S %d-%m-%Y")
    query = "SELECT value FROM indicators WHERE indicator_id = ? AND attribute = 'Title'"
    # cur = conn.cursor()
    cur.execute(query, (indic_id,))
    title_list = cur.fetchall()
    # I need to have exact 1 title
    if len(title_list) == 0:
        log_msg = "No Title defined for Indicator ID %s"
        logging.error(log_msg, indic_id)
        return False
    elif len(title_list) == 1:
        title = title_list[0][0]
    else:
        log_msg = "Multiple titles (?) defined for Indicator ID %s"
        logging.error(log_msg, len(title_list), indic_id)
        return False
    # OK, 1 title found. Convert it to a name
    name = 'dmow-ind' + str(indic_id).zfill(3) + '-' + title
    # name = 'tstind' + str(indic_id).zfill(3) + '-' + title
    name = name[0:100]
    name = re.sub('[^0-9a-zA-Z_\-]', '_', name).lower()
    logging.info("Name: %s", name)
    my_param = {
        'name': name,
        'title': title,
        'owner_org': config['OpenData']['owner_org'],
        'license_id': config['OpenData']['license_id'],
    }
    logging.debug("Parameters: %s", my_param)
    try:
        pkg = ckan_conn.action.package_create(**my_param)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Package Create not successful %s %s"
        logging.error(log_msg, e, ec)
        return False
    else:
        # Collect Package information and set it in the database.
        try:
            val_id = pkg['id']
        except:
            log_msg = "Create package with no errors, but no package ID found..."
            logging.error(log_msg)
            return False
        else:
            # Store package ID in indicators table
            query = "INSERT INTO indicators (indicator_id, attribute, value, created) " \
                    "VALUES (?, 'id', ?, ?)"
            try:
                cur.execute(query, (indic_id, val_id, now))
            except:
                log_msg = "Insert query failed **%s**, indic_id: %s, Value_id: %s"
                logging.error(log_msg, query, indic_id, val_id)
                return False
            conn.commit()
        log_msg = 'Looks like I have my package...'
        logging.info(log_msg)
    log_msg = "End of create_package processing for Indicator %s"
    logging.info(log_msg, indic_id)
    return True


def update_package(indic_id, ckan_conn):
    """
    This procedure will update Package information for the indicator ID.
    :param indic_id:
    :return:
    """
    log_msg = "Update Package for Indicator %s"
    logging.info(log_msg, indic_id)
    # Get ID of the package
    query = "SELECT value FROM indicators WHERE attribute = 'id' AND indicator_id = ?"
    cur.execute(query, (indic_id,))
    res = cur.fetchone()
    doc_id = res[0]  # Remember ID of the package in params dictionary
    # First check if there is a 'Cijfers' URL available.
    # If not, then set dataset to private.
    if check_resource(indic_id, 'cijfers'):
        set_pkg_public(indic_id, ckan_conn, doc_id)
    else:
        set_pkg_private(ckan_conn, doc_id)


def set_pkg_private(ckan_conn, doc_id):
    """
    This indicator does not have a cijfers file associated, set it to 'private'.
    :param ckan_conn:
    :return:
    """
    params = {
        'id': doc_id,
        'private': True,
    }
    log_msg = "Trying to update package with params %s"
    logging.debug(log_msg, params)
    try:
        pkg = ckan_conn.action.package_patch(**params)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Package Update not successful %s %s"
        logging.error(log_msg, e, ec)
    else:
        log_msg = "Package Update successful %s"
        logging.info(log_msg, pkg)
    return


def set_pkg_public(indic_id, ckan_conn, doc_id):
    """
    This Indicator has a cijfer file available, set this available on Open Data.
    :param indic_id:
    :param ckan_conn:
    :return:
    """
    params = {
        'id': doc_id,
        'private': False,
    }
    # First get attribute names for extra fields
    query = "SELECT attribute, od_field FROM attribute_action WHERE action = 'Extra'"
    cur.execute(query)
    res = cur.fetchall()
    # Remember the attribute - od_field translation
    od_field = {}
    for [k, v] in res:
        od_field[k] = v
    # Then get values for the attribute names
    attribs = [res[i][0] for i in range(len(res))]
    # With attribute names, find corresponding values in indicators table
    query = "SELECT attribute, value FROM indicators WHERE indicator_id = ? AND attribute IN " + str(tuple(attribs))
    logging.debug("Query: %s", query)
    cur.execute(query, (indic_id,))
    res = cur.fetchall()
    extra_arr = []
    for [k, v] in res:
        attrib_dict = {
            'key': od_field[k],  # Use human readable label as key
            'value': v
        }
        extra_arr.append(attrib_dict)
    # Add extras dictionary to params dictionary
    params['extras'] = extra_arr
    # Then get attribute names for Main fields
    query = "SELECT attribute, od_field FROM attribute_action " \
            "WHERE action = 'Main' AND source = 'Dataroom' AND target = 'Dataset'"
    cur.execute(query)
    res = cur.fetchall()
    # Remember the attribute - od_field translation for Main field
    od_field = {}
    for [k, v] in res:
        od_field[k] = v
    # Then get values for the Main attribute names
    attribs = [res[i][0] for i in range(len(res))]
    # With attribute names, find corresponding values in indicators table
    query = "SELECT attribute, value FROM indicators WHERE indicator_id = ? AND attribute IN " + str(tuple(attribs))
    logging.debug("Query: %s", query)
    cur.execute(query, (indic_id,))
    res = cur.fetchall()
    # Add the values to params dictionary
    for [k, v] in res:
        params[od_field[k]] = v
    log_msg = "Trying to update package with params %s"
    logging.debug(log_msg, params)
    try:
        ckan_conn.action.package_patch(**params)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Package Update not successful %s %s"
        logging.error(log_msg, e, ec)
        return
    log_msg = "Package Update successful for indicator ID %s, now update cijfers."
    logging.info(log_msg, indic_id)
    # I know for sure that the cijfers.xml is on the FTP server, so create/update cijfers resource.
    manage_resource(indic_id, ckan_conn, doc_id, 'cijfers')
    # Check other resource types
    for res_type in ['commentaar', 'cognos']:
        if check_resource(indic_id, res_type):
            manage_resource(indic_id, ckan_conn, doc_id, res_type)
    return


def check_resource(indic_id, res_type):
    """
    This procedure will check if the resource URL is available, so if the resource needs to be created/updated or
    removed.
    :param indic_id:
    :param res_type:
    :return:
    """
    attribute = "url_" + res_type
    query = "SELECT value FROM indicators WHERE attribute = ? AND indicator_id = ?"
    cur.execute(query, (attribute, indic_id,))
    res = cur.fetchall()
    log_msg = "Check for Resource %s, Result: %s"
    logging.debug(log_msg, res_type, res)
    if len(res) == 0:
        return False
    elif len(res) == 1:
        return True
    else:
        log_msg = "Unexpected number of URLs found for Resource %s and indicator ID %s"
        logging.error(log_msg, res_type, indic_id)
        return False


def manage_resource(indic_id, ckan_conn, doc_id, res_type):
    """
    This function will manage the resource patch. Check if cijfer resource or commentaar resource needs to be
    created or updated.
    A resource needs to have resource ID in table indicators - then it will be updated.
    If there is no entry in the indicators table, then the resource will be created.
    :param indic_id: Indicator ID that is currently being processed.
    :param ckan_conn: Connector to the ckan Open Data website.
    :param doc_id: Package ID of the package that is currently handled.
    :return: nothing
    """
    params = {
        'package_id': doc_id,
    }
    target_type = {
        'cijfers': 'CijfersResource',
        'commentaar': 'CommentaarResource',
        'cognos': 'CognosResource'
    }
    # Collect data fields for resource
    # First get attribute names for Resource from Dataroom
    query = "SELECT attribute, od_field FROM attribute_action " \
            "WHERE action = 'Resource' AND ((source = 'Dataroom') OR (source = 'Repository')) " \
            "AND target = ?"
    cur.execute(query, (target_type[res_type],))
    res = cur.fetchall()
    # Remember the attribute - od_field translation for Main field
    od_field = {}
    for [k, v] in res:
        od_field[k] = v
    # Then get values for these Resource attribute names
    attribs = [res[i][0] for i in range(len(res))]
    # With attribute names, find corresponding values in indicators table
    query = "SELECT attribute, value FROM indicators WHERE indicator_id = ? AND attribute IN " + str(tuple(attribs))
    logging.debug("Query: %s", query)
    cur.execute(query, (indic_id,))
    res = cur.fetchall()
    # Add the values with Open Data Keys to params dictionary
    for [k, v] in res:
        params[od_field[k]] = v
    # Now check if this is a new resource or an update for a resource
    id_name = "id_" + res_type
    query = "SELECT attribute, value FROM indicators WHERE indicator_id = ? AND attribute = ?"
    cur.execute(query, (indic_id, id_name, ))
    res = cur.fetchall()
    log_msg = "Result for id_name %s: %s"
    logging.debug(log_msg, id_name, res)
    log_msg = "Length: %s"
    logging.debug(log_msg, len(res))
    if len(res) == 0:
        # Resource_Create
        create_resource(indic_id, ckan_conn, params, res_type)
    elif len(res) == 1:
        params['id'] = res[0][1]
        update_resource(indic_id, ckan_conn, params)
    else:
        log_msg = "Unexpected number of Resource record IDs for indicator ID %s and resource %s"
        logging.error(log_msg, indic_id, res_type)
    return


def create_resource(indic_id, ckan_conn, params, res_type):
    """
    This procedure will create a resource.
    :param ckan_conn:
    :param params:
    :return:
    """
    logging.debug("Trying to create resource, parameters: %s (type: %s)", params, res_type)
    now = strftime("%H:%M:%S %d-%m-%Y")
    try:
        pkg = ckan_conn.action.resource_create(**params)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Resource Create not successful %s %s"
        logging.error(log_msg, e, ec)
        return
    log_msg = "Resource has been created: %s, Update info for Indicator: %s"
    logging.debug(log_msg, pkg, indic_id)
    # Collect Resource information and set it in the database.
    try:
        val_id = pkg['id']
    except:
        log_msg = "Create resource with no errors, but no package ID found..."
        logging.error(log_msg)
        return
    else:
        # Store resource ID in indicators table
        attribute = "id_" + res_type
        query = "INSERT INTO indicators (indicator_id, attribute, value, created) " \
                "VALUES (?, ?, ?, ?)"
        try:
            cur.execute(query, (indic_id, attribute, val_id, now))
        except:
            log_msg = "Insert query failed **%s**, indic_id: %s, Value_id: %s"
            logging.error(log_msg, query, indic_id, val_id)
            return
        conn.commit()
    log_msg = 'Looks like I have my %s Resource...'
    logging.info(log_msg, res_type)


def update_resource(indic_id, ckan_conn, params):
    """
    This procedure will update an existing resource.
    No need to specify cijfers / commentaar resource type.
    :param ckan_conn:
    :param params:
    :return:
    """
    logging.debug("Trying to update resource, parameters: %s", params)
    try:
        pkg = ckan_conn.action.resource_patch(**params)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Resource Update not successful %s %s"
        logging.error(log_msg, e, ec)
        return
    log_msg = "Resource has been updated: %s, Update info for Indicator: %s"
    logging.debug(log_msg, pkg, indic_id)
    # Test if resource_id from updated package is same as original resource_id.
    if pkg['id'] == params['id']:
        logging.debug("Resource ID returned same as ID sent.")
    else:
        logging.error("Resource ID returned differend from ID sent")


def remove_resource(ckan_conn, indic_id, res_type):
    """
    This procedure knows that resource URL does not exist. If there is a resource on Open Data platform, then
    remove this resource.
    :param ckan_conn:
    :return:
    """
    attribute = "id_" + res_type
    query = "SELECT value FROM indicators WHERE attribute = ? AND indicator_id = ?"
    cur.execute(query, (attribute, indic_id,))
    res = cur.fetchall()
    log_msg = "Check for Resource %s, Result: %s"
    logging.debug(log_msg, res_type, res)
    if len(res) == 0:
        # OK, resource does not exist, no further action.
        return
    elif len(res) > 1:
        log_msg = "Unexpected number of URLs found for Resource %s and indicator ID %s, I'll remove them all."
        logging.error(log_msg, res_type, indic_id)
    for row in res:
        params = {
            'id': row[0],
        }
        try:
            pkg = ckan_conn.action.resource_delete(**params)
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Resource Delete not successful %s %s"
            logging.error(log_msg, e, ec)
        else:
            log_msg = "Resource has been deleted: %s for Indicator: %s"
            logging.debug(log_msg, pkg, indic_id)
        # Remove all id_resource entries
        query = "DELETE FROM indicators WHERE attribute = ? AND indicator_id = ?"
        cur.execute(query, (attribute, indic_id, ))
    return


def get_ckan_conn():
    """
    Configure the connection to ckan Open Data Platform.
    :return:
    """
    logging.debug("Setup connection to ckan Server")
    url = config['CKANServer']['url']
    api = config['CKANServer']['api']
    try:
        ckan_conn = ckanapi.RemoteCKAN(url, apikey=api)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Connect to RemoteCKAN not successful %s %s"
        logging.critical(log_msg, e, ec)
        sys.exit(1)
    return ckan_conn


def scan_for_files():
    """
    Function to scan input directory for new files in sequence: commentaar - cijfers - metadata.
    If a file is found, call file handling procedure.
    :return:
    """
    # Get ckan connection first
    ckan_conn = get_ckan_conn()
    # Then set-up for ftp connection.
    scandir = config['Main']['scandir']
    handledir = config['Main']['handledir']
    log_msg = "Scan %s for files commentaar*.xml"
    logging.debug(log_msg, scandir)
    log_msg = "Get my FTP Connection"
    logging.debug(log_msg)
    ftp = ftp_connection()
    # Don't use os.listdir in for loop since I'll move files. For loop will get confused.
    # Extract filelist first.
    filelist = [file for file in os.listdir(scandir) if ('cijfers' in file) or ('commentaar' in file)]
    for file in filelist:
        log_msg = "Filename: %s"
        logging.debug(log_msg, file)
        move_file(file, scandir, handledir)  # Move file done in own function, such a hassle...
        if 'empty' in file:
            remove_file(ckan_conn, ftp, file=os.path.join(handledir, file))
        else:
            load_file(ftp, file=os.path.join(handledir, file))
        size_of_file(handledir, file)
        url_in_db(file)
    # Now close FTP Object
    ftp.close()
    # Now handle meta-data
    filelist = [file for file in os.listdir(scandir) if 'metadata' in file]
    for file in filelist:
        log_msg = "Filename: %s"
        logging.debug(log_msg, file)
        move_file(file, scandir, handledir)  # Move file done in own function, such a hassle...
        if 'empty' in file:
            # remove_metadata(file)
            pass
        else:
            # Get indic_id before adding pathname to filename.
            indic_id = indic_from_file(file)
            filename = os.path.join(handledir, file)
            load_metadata(filename, indic_id, ckan_conn)
    return


# Get ini-file first.
modulename = get_modulename()
config = get_inifile()
# Now configure logfile
logfilename = get_logfilename()
logging.basicConfig(format='%(asctime)s:%(levelname)s:%(module)s:%(funcName)s:%(lineno)d:%(message)s',
                    datefmt='%d/%m/%Y %H:%M:%S', filename=logfilename, level=logging.DEBUG)
logging.info('\n\n\nStart Application')
# Get my database connection
conn = connect2db()
cur = conn.cursor()
scan_for_files()
# Close database connection
conn.close()
logging.info('End Application')
