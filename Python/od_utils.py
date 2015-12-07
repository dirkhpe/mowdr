#!/opt/csw/bin/python3

"""
This script consolidates a number of Open Data utilities.
Utilities include 'get package information, list packages, ...'
"""

import json
import logging
import sys
import ckanapi
from lib import my_env


def show_resource_view_list():
    resource_name = input("Resource ID: ")
    resource_view_list(resource_name)
    return


def show_resource_view():
    resource_name = input("Resource View ID: ")
    resource_view(resource_name)
    return


def show_resource():
    package_name = input("Resource ID: ")
    resource_show(package_name)
    return


def show_pkg_name():
    package_name = input("Package name: ")
    package_show(package_name)
    return


def show_pkg_indic():
    indic_id = input("Indicator ID: ")
    try:
        indic_id = int(indic_id)
    except ValueError:
        msg = str(indic_id) + " is not an integer."
        print(msg)
        logging.fatal(msg)
        sys.exit(1)
    package_name = my_env.get_name_from_indic(config, indic_id)
    package_show(package_name)
    return


def resource_view(resource_view_id):
    """
    Return the resource view metadata.
    :param resource_view_id:
    :return:
    """
    if resource_view_id is None:
        print('Resource View ID needs to be defined!')
    else:
        try:
            res = ckan_conn.action.resource_view_show(id=resource_view_id)
        except ckanapi.NotFound:
            msg = "Resource " + str(resource_view_id) + " not found."
            print(msg)
            logging.error(msg)
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Resource View Metadata not successful %s %s"
            logging.error(log_msg, e, ec)
            return False
        else:
            # print("Name: " + res['name'])
            # print("ID: " + res['id'])
            f.write('Result of resource_show:\n')
            f.write('-----------------------\n')
            f.write(json.dumps(res, indent=4))
            logging.info("Output written to " + outfile)


def resource_view_list(resource_name):
    """
    Return the resource view list.
    :param resource_name:
    :return:
    """
    if resource_name is None:
        print('Resource Name needs to be defined!')
    else:
        try:
            res = ckan_conn.action.resource_view_list(id=resource_name)
        except ckanapi.NotFound:
            msg = "Resource " + str(resource_name) + " not found."
            print(msg)
            logging.error(msg)
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Resource View List not successful %s %s"
            logging.error(log_msg, e, ec)
            return False
        else:
            # print("Name: " + res['name'])
            # print("ID: " + res['id'])
            f.write('Result of resource_show:\n')
            f.write('-----------------------\n')
            f.write(json.dumps(res, indent=4))
            logging.info("Output written to " + outfile)


def resource_show(resource_name):
    """
    Return the metadata of a resource.
    :param resource_name:
    :return:
    """
    if resource_name is None:
        print('Resource Name needs to be defined!')
    else:
        try:
            res = ckan_conn.action.resource_show(id=resource_name, include_tracking=1)
        except ckanapi.NotFound:
            msg = "Resource " + str(resource_name) + " not found."
            print(msg)
            logging.error(msg)
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Resource Show not successful %s %s"
            logging.error(log_msg, e, ec)
            return False
        else:
            print("Name: " + res['name'])
            print("ID: " + res['id'])
            f.write('Result of resource_show:\n')
            f.write('-----------------------\n')
            f.write(json.dumps(res, indent=4))
            logging.info("Output written to " + outfile)


def package_show(package_name):
    """
    URL: http://ckan-001.corve.openminds.be/api/3/action/package_show?
    id=dmow-ind003-filezwaarte_op_het_hoofdwegennet&include_tracking=True
    Return the metadata of a dataset (package) and its resources.
    :param package_name:
    :return:
    """
    if package_name is None:
        print('Package Name needs to be defined!')
    else:
        try:
            res = ckan_conn.action.package_show(id=package_name, include_tracking=1)
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Package Show not successful %s %s"
            logging.error(log_msg, e, ec)
            return False
        else:
            print("Name: " + res['name'])
            print("ID: " + res['id'])
            print("Organization: " + res['organization']['name'])
            f.write('Result of package_show:\n')
            f.write('-----------------------\n')
            f.write(json.dumps(res, indent=4))
            logging.info("Output written to " + outfile)


def package_list():
    """
    URL: http://ckan-001.corve.openminds.be/api/3/action/package_list
    Return the metadata of a dataset (package) and its resources.
    :return:
    """
    try:
        # res = ckan_conn.action.package_list(limit=20)
        res = ckan_conn.action.package_list()
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Package List not successful %s %s"
        logging.error(log_msg, e, ec)
        return False
    else:
        f.write('Result of package_list:\n')
        f.write('-----------------------\n')
        f.write(json.dumps(res, indent=4))


def get_ckan_conn():
    """
    Configure the connection to ckan Open Data Platform.
    :return:
    """
    logging.debug("Setup connection to ckan Server")
    url = config['CKANServer']['url']
    api = config['CKANServer']['api']
    try:
        ckanconn = ckanapi.RemoteCKAN(url, apikey=api)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Connect to RemoteCKAN not successful %s %s"
        logging.critical(log_msg, e, ec)
        sys.exit(1)
    return ckanconn


def handle_selection(sel):
    """
    This method validates the selection. Selection needs to be numeric and between 1 and number of options.
    :param sel: Selection entered by the user.
    :return: if validation successful, then sel - 1 (index for utility), else False and sys.exit
    """
    # Check on integer
    try:
        sel = int(sel)
    except ValueError:
        msg = str(sel) + " is not an integer."
        print(msg)
        logging.fatal(msg)
        sys.exit(1)
    # Check on in-range and call function all in one
    try:
        utilities[sel - 1]()
    except IndexError:
        msg = "Integer out-of-range: " + str(sel)
        print(msg)
        logging.fatal(msg)
        sys.exit()

# Set-up environment
utility_desc = ['Display package list',
                'Show package based on name',
                'Show package based on indicator ID',
                'Show resource based on resource ID',
                'Show view list for resource ID',
                'Show resource view metadata for resource view ID']
utilities = [package_list,
             show_pkg_name,
             show_pkg_indic,
             show_resource,
             show_resource_view_list,
             show_resource_view]

# Get ini-file first.
# Setup Proxy Server
# os.environ['http_proxy'] = 'http://proxyservers.vlaanderen.be:8080'
projectname = 'mowdr'
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname)
# Now configure logfile
my_env.init_logfile(config, modulename)
logging.info('Start Application')
# Get ckan connection
ckan_conn = get_ckan_conn()
# Get file handle
logdir = config['Main']['logdir']
outfile = logdir + "/od_utils.txt"
f = open(outfile, 'w')
selection = 0
print("Open Data Utilities")
print("===================")
for option in utility_desc:
    selection += 1
    print(str(selection) + ": " + option)
choice = input("Enter selection number: ")
handle_selection(choice)
f.close()
logging.info('End Application')
