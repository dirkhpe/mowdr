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
    Load file on mobielvlaanderen.be. Remove the file first if it exists already (since it is an older version).
    If remove_only is True, then only remove the file.
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


def remove_file(ftp, file=None):
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
        return
    log_msg = "Looks like file %s is removed from FTP Server."
    logging.debug(log_msg, file)
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


def load_metadata(metafile, indic_id, ckan_conn):
    """
    Read the file with metadata and add or replace the information to table indicators.
    Call function to create dataset if this is a new dataset.
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
    query = "SELECT attribute FROM attribute_action " \
            "WHERE source = 'Dataroom' AND target = 'Dataset'"
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
            cur.execute(query, (indic_id, child.tag, child.text.strip(), now))
            # Add 'notes' field (copy of definitie)
            if child.tag.lower() == 'definitie':
                cur.execute(query, (indic_id, 'notes', child.text.strip(), now))
        elif child.tag != 'id':
            log_msg = "Found Dataroom Attribute **" + child.tag + "** not required for Open Data Dataset"
            logging.warning(log_msg)
    conn.commit()
    # Now check if dataset exist already: is there an ID available in the indicators table for this indicator.
    query = "SELECT value FROM indicators WHERE attribute = 'id' and indicator_id = ?"
    cur.execute(query, (indic_id,))
    values_lst = cur.fetchall()
    # I want to have 0 or 1 rows in the list
    if len(values_lst) == 0:
        log_msg = "Open Data dataset is not registered for Indicator ID %s, call to register"
        logging.info(log_msg, indic_id)
        create_package(indic_id, ckan_conn)
    elif len(values_lst) == 1:
        log_msg = "Open Data dataset exists for Indicator ID %s, no further action"
        logging.info(log_msg, indic_id)
    else:
        log_msg = "Multiple Open Data dataset links found for Indicator ID %s, please review"
        logging.warning(log_msg, indic_id)
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
    }
    my_param['owner_org'] = config['OpenData']['owner_org']
    my_param['license_id'] = config['OpenData']['license_id']
    logging.debug("Parameters: %s", my_param)
    try:
        pkg = ckan_conn.action.package_create(**my_param)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Package Create not successful %s %s"
        logging.error(log_msg, e, ec)
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


def update_package(indic_id, ckan_conn):
    """
    This procedure will update Package information for the indicator ID.
    :param indic_id:
    :return:
    """
    params = {}
    log_msg = "Update Package for Indicator %s"
    logging.info(log_msg, indic_id)
    # Get ID of the package
    query = "SELECT value FROM indicators WHERE attribute = 'id' AND indicator_id = ?"
    cur.execute(query, (indic_id,))
    res = cur.fetchone()
    params['id'] = res[0]  # Remember ID of the package in params dictionary
    # Now get extra fields that need to be populated
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
    # Add extras dictionary to params dictionary
    for [k, v] in res:
        params[od_field[k]] = v
    print("%s" % params)
    log_msg = "Trying to update package"
    logging.debug(log_msg)
    try:
        pkg = ckan_conn.action.package_update(**params)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Package Update not successful %s %s"
        logging.error(log_msg, e, ec)
    else:
        log_msg = "Package Update successful %s"
        logging.info(log_msg, pkg)
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
    scandir = config['Main']['scandir']
    handledir = config['Main']['handledir']
    log_msg = "Scan %s for files commentaar*.xml"
    logging.debug(log_msg, scandir)
    log_msg = "First get my FTP Connection"
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
            remove_file(ftp, file=os.path.join(handledir, file))
        else:
            load_file(ftp, file=os.path.join(handledir, file))
        url_in_db(file)
    # Now close FTP Object
    ftp.close()
    # Now handle meta-data
    # Get ckan connection first
    ckan_conn = get_ckan_conn()
    filelist = [file for file in os.listdir(scandir) if 'metadata' in file]
    for file in filelist:
        log_msg = "Filename: %s"
        logging.debug(log_msg, file)
        move_file(file, scandir, handledir)  # Move file done in own function, such a hassle...
        if 'empty' in file:
            # remove_metadata(file)
            pass
        else:
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


