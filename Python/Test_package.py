__author__ = 'Dirk Vermeylen'

import json
import logging
import sys
import ckanapi
from lib import my_env


def package_show(package_name):
    """
    URL: http://ckan-001.corve.openminds.be/api/3/action/help_show?name=package_show
    Return the metadata of a dataset (package) and its resources.
    :param package_name:
    :return:
    """
    logdir = config['Main']['logdir']
    outfile = logdir + "/package.json"
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
            f = open(outfile, 'w')
            f.write(json.dumps(res, indent=4))
            f.close()
            logging.info("Output written to " + outfile)


def package_list():
    """
    URL: http://ckan-001.corve.openminds.be/api/3/action/package_show?
    id=dmow-ind003-filezwaarte_op_het_hoofdwegennet&include_tracking=True
    Return the metadata of a dataset (package) and its resources.
    :return:
    """
    logdir = config['Main']['logdir']
    outfile = logdir + "/package_list.json"
    try:
        res = ckan_conn.action.package_list()
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Package List not successful %s %s"
        logging.error(log_msg, e, ec)
        return False
    else:
        f = open(outfile, 'w')
        f.write(json.dumps(res, indent=4))
        f.close()


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


# Get ini-file first.
projectname = 'mowdr'
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname)
# Now configure logfile
my_env.init_logfile(config, modulename)
logging.info('Start Application')
ckan_conn = get_ckan_conn()
package_show('dmow-ind003-filezwaarte_op_het_hoofdwegennet')
# package_show('faillissementen2')
# package_list()
logging.info('End Application')
