"""
This module consolidates all local configuration for the script, including modulename collection for logfile name
setup and initializing the config file.
Also other utilities find their home here.
"""

import configparser
import datetime
import logging
import logging.handlers
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
    This is for basic logfile configuration. If a Log Handler is required, then function init_loghandler needs to be
    used.
    :param config: Reference to the configuration ini file. Directory for logfile should be
    in section Main entry logdir.
    :param modulename: The name of the module. Each module will create it's own logfile.
    :return: Directory and name of the logfile includint computername.
    """
    logdir = config['Main']['logdir']
    print("Logdir: " + logdir)
    # Current Date for filename
    currdate = datetime.date.today().strftime("%Y%m%d")
    # Extract Computername
    computername = platform.node()
    # Define logfileName
    logfile = logdir + "/" + modulename + "_" + computername + \
        "_" + currdate + ".log"
    logging.basicConfig(format='%(asctime)s|%(module)s|%(funcName)s|%(lineno)d|%(levelname)s|%(message)s',
                        datefmt='%d/%m/%Y|%H:%M:%S', filename=logfile, level=logging.INFO)
    return logfile


def init_loghandler(config, modulename):
    """
    This function initializes the loghandler. Logfilename consists of calling module name + computername.
    Logfile directory is read from the project .ini file.
    Format of the logmessage is specified in basicConfig function.
    This is for Log Handler configuration. If basic log file configuration is required, then use init_logfile.
    :param config: Reference to the configuration ini file. Directory for logfile should be
    in section Main entry logdir.
    :param modulename: The name of the module. Each module will create it's own logfile.
    :return: Log Handler
    """
    logdir = config['Main']['logdir']
    # Extract Computername
    computername = platform.node()
    # Define logfileName
    logfile = logdir + "/" + modulename + "_" + computername + ".log"
    # Configure the root logger
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)
    # Create Console Handler
    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    # Create Rotating File Handler
    # Get logfiles of 1M
    maxbytes = 1024 * 1024
    rfh = logging.handlers.RotatingFileHandler(logfile, maxBytes=maxbytes, backupCount=5)
    # Create Formatter for file
    formatter_file = logging.Formatter(fmt='%(asctime)s|%(module)s|%(funcName)s|%(lineno)d|%(levelname)s|%(message)s',
                                       datefmt='%d/%m/%Y|%H:%M:%S')
    formatter_console = logging.Formatter(fmt='%(asctime)s - %(module)s - %(funcName)s - %(lineno)d - %(levelname)s -'
                                              ' %(message)s',
                                          datefmt='%H:%M:%S')
    # Add Formatter to Console Handler
    ch.setFormatter(formatter_console)
    # Add Formatter to Rotating File Handler
    rfh.setFormatter(formatter_file)
    # Add Handler to the logger
    logger.addHandler(ch)
    logger.addHandler(rfh)
    return logger


def get_inifile(projectname, scriptname):
    """
    Read Project configuration ini file in subdirectory properties.

    :param projectname: Name of the project.

    :param scriptname: Name of the calling application. This is used to calculate the config file path.

    :return: Object reference to the inifile.
    """
    # Use Project Name as ini file.
    # TODO: review procedure to get directory name instead of relative properties/ path.
    (filepath, filename) = os.path.split(scriptname)
    configfile = filepath + "/properties/" + projectname + ".ini"
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
        log_msg = "File %s exists in targetdir %s, removing from targetdir."
        logging.debug(log_msg, file2move, targetdir)
        os.remove(os.path.join(targetdir, file2move))
    log_msg = "OK, File %s does not exists in targetdir %s now."
    logging.debug(log_msg, file2move, targetdir)
    os.rename(os.path.join(sourcedir, file2move), os.path.join(targetdir, file2move))
    return


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
    The filename format is resource_indicid.ext or resource_indicid.empty.ext

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
    :return: dictionary with known resource types and resource label.
    """
    resource_types = {'cijfersxml': 'Cijfers (XML)',
                      'cijferstable': 'Cijfers (Tabel)',
                      'commentaar': 'Commentaar',
                      'powerbi': 'Rapport (PowerBI)'}
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
    This method will calculate unique name for the dataset on Open Data platform. The name exists of the url_prefix
    that is defined in OpenData section in ini file and the indicator number.

    :param config:

    :param indic_id:

    :return: unique dataset name.
    """
    name = config['OpenData']['url_prefix'] + str(indic_id).zfill(3)
    name = name[0:100]
    name = re.sub('[^0-9a-zA-Z_\-]', '_', name).lower()
    return name


def get_dataset_id(indic_id):
    """
    This method will calculate the dataset indicator (indXXX) for usage in dcat_ap profiles.

    :param indic_id:

    :return: dataset_id.
    """
    dataset_id = '_ind' + str(indic_id).zfill(3)
    return dataset_id


def get_global_header(cfg):
    """
    This method will return the Global header to include in html pages, such as the 'Bijsluiter'.

    :param cfg: Config object

    :return: Global header string
    """
    gh_id = cfg['OpenData']['global_header']
    header_str = """
<header>
    <script type="text/javascript" src="//widgets.vlaanderen.be/widget/live/{gh_id}">
    </script>
</header>
    """.format(gh_id=gh_id)
    return header_str


def get_global_footer(cfg):
    """
    This method will return the Global footer to include in html pages, such as the 'Bijsluiter'.

    :param cfg: Config object

    :return: Global footer string
    """
    gf_id = cfg['OpenData']['global_footer']
    footer_str = """
<header>
    <script type="text/javascript" src="//widgets.vlaanderen.be/widget/live/{gf_id}">
    </script>
</header>
    """.format(gf_id=gf_id)
    return footer_str
