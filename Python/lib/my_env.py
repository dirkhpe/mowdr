"""
This module consolidates all local configuration for the script, including modulename collection for logfile name
setup and initializing the config file.
Also other utilities find their home here.
"""

import configparser
import datetime
import logging
import os
import platform
import re
import sys


def get_modulename(scriptname):
    """
    Modulename is required for logfile and for properties file.
    :param scriptname: Name of the script for which modulename is required. Use __file__.
    :return: Module Filename from the calling script.
    """
    # Extract calling application name
    (filepath, filename) = os.path.split(scriptname)
    (module, fileext) = os.path.splitext(filename)
    return module


def init_logfile(config, modulename):
    """
    This function initializes the logfile. Logfilename consists of calling module name + computername + date.
    Logfile directory is read from the project .ini file.
    Format of the logmessage is specified in basicConfig function.
    :param config: Reference to the configuration ini file. Directory for logfile should be
    in section Main entry logdir.
    :param modulename: The name of the module. Each module will create it's own logfile.
    :return: Directory and name of the logfile includint computername.
    """
    logdir = config['Main']['logdir']
    # Current Date for filename
    currdate = datetime.date.today().strftime("%Y%m%d")
    # Extract Computername
    computername = platform.node()
    # Define logfileName
    logfile = logdir + "/" + modulename + "_" + computername + \
        "_" + currdate + ".log"
    logging.basicConfig(format='%(asctime)s|%(module)s|%(funcName)s|%(lineno)d|%(levelname)s|%(message)s',
                        datefmt='%d/%m/%Y|%H:%M:%S', filename=logfile, level=logging.DEBUG)
    return logfile


def get_inifile(projectname):
    """
    Read Project configuration ini file in subdirectory properties.
    :param projectname: Name of the project.
    :return: Object reference to the inifile.
    """
    # Use Project Name as ini file.
    # TODO: review procedure to get directory name instead of relative properties/ path.
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


def get_array(inp_obj):
    """
    The purpose of the method is to convert input string or input array into a string that can be used in SELECT ...
    WHERE attribute IN (inp1, inp2, ...)
    :param inp_obj: String or Array (list). Error on other values. String will be surrounded by quotes. Values in the
    array will not be surrounded by quotes.
    :return: string to use in SQL query
    """
    if isinstance(inp_obj, list):
        outp_obj = str(tuple(inp_obj))
    elif isinstance(inp_obj, str):
        outp_obj = "('" + inp_obj + "')"
    else:
        logging.error("Input %s cannot be converted, type is %s.", str(inp_obj), type(inp_obj).__name__)
        outp_obj = ""
    return outp_obj


def indic_from_file(filename):
    """
    This method will extract the indicator ID from the filename.
    The indicator number is between _ and first . (empty. can be there before a potential second dot.)
    :param filename:
    :return: indic_id (numeric)
    """
    # log_msg = "Getting indicator ID from %s"
    # logging.debug(log_msg, filename)
    parts = filename.split('_')
    # TODO This algorithm cannot handle filenames that do not contain _. Index will be out of bounds.
    indic_array = parts[1].split('.')
    indic_id = int(indic_array[0])
    # log_msg = "Indicator ID: %s"
    # logging.debug(log_msg, indic_id)
    return indic_id


def type_from_file(filename):
    """
    This procedure will extract the Type from the filename.
    The resource type is before first _ . Resource types are returned in lowercase.
    :param filename:
    :return: resource type
    """
    file = os.path.basename(filename)
    # log_msg = "Getting Resource type from %s (%s)"
    # logging.debug(log_msg, file, filename)
    parts = file.split('_')
    # TODO This algorithm cannot handle filenames that do not contain _. Index will be out of bounds.
    res_type = parts[0].lower()
    # log_msg = "Resource Type: %s"
    # logging.debug(log_msg, res_type)
    return res_type


def attr_from_file(attribute, file):
    """
    This method will provide attribute name from file name. Underscore is added between attribute and file.
    :param attribute: name to create attribute with, such as url or id. Don't add underscore.
    :param file: Filename for which type is searched.
    :return: attribute and filename, example: url_cijfersxml or id_commentaar
    """
    # logging.debug("Attribute: %s, File: %s", attribute, file)
    filetype = type_from_file(file)
    attr_name = attribute + "_" + filetype
    # logging.debug("Calculated attribute name: %s", attr_name)
    return attr_name


def get_resource_types():
    """
    This method will return all known resource types in an array.
    To do: convert all resource type handling in a class, create an iterator here.
    :return: array with known resource types.
    """
    resource_types = ['cijfersxml',
                      'cijferstable',
                      'commentaar',
                      'cognos']
    return resource_types


def get_resource_type_file():
    """
    This method will return all known resource types in an array. The resource types need to have a file associated.
    :return: array with known resource types.
    """
    resource_types = ['cijfersxml',
                      'cijferstable',
                      'commentaar']
    return resource_types


def get_target(resource_type):
    """
    This method will return target name as used in table attribute_action for a specific resource type.
    :param resource_type:
    :return: Target name
    """
    target_type = {
        'cijfersxml': 'CijfersXMLResource',
        'cijferstable': 'CijfersTableResource',
        'commentaar': 'CommentaarResource',
        'cognos': 'CognosResource'
    }
    if known_resource_type(resource_type):
        return target_type[resource_type]


def known_resource_type(resource_type):
    """
    This method will return True for a known / valid resource type and false for an invalid resource type.
    :param resource_type:
    :return: True / False
    """
    resource_types = get_resource_types()
    if resource_type in resource_types:
        return True
    else:
        log_msg = "Unknown Resource Type: %s, not in %s"
        logging.error(log_msg, resource_type, str(resource_types))
        sys.exit(1)


def get_name_from_indic(config, indic_id):
    """
    This method will calculate unique name for the dataset on Open Data platform.
    :param indic_id:
    :return: unique dataset name.
    """
    name = config['OpenData']['url_prefix'] + str(indic_id).zfill(3)
    name = name[0:100]
    name = re.sub('[^0-9a-zA-Z_\-]', '_', name).lower()
    return name
