#!/opt/csw/bin/python3

import json
import logging
import sys
import ckanapi
from lib import my_env


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
            f.write('\n\n\n')
            logging.info("Output written to " + outfile)


def package_list():
    """
    URL: http://ckan-001.corve.openminds.be/api/3/action/package_list
    Return the metadata of a dataset (package) and its resources.
    :return:
    """
    try:
        res = ckan_conn.action.package_list(limit=20)
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
        f.write('\n\n\n')


def set_pkg_private(doc_id):
    """
    Set the dataset to 'private'.
    :param doc_id:
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
logdir = config['Main']['logdir']
outfile = logdir + "/" + modulename + ".txt"
f = open(outfile, 'w')
package_show('dmow-ind051-aantal_zware_ongevallen_met_grote_schade_op_de_westerschelde__met_mogelijke_gevolgen_voo')
set_pkg_private('18d67cd3-a9c5-45aa-b5bc-9be94c6cb258')
# package_list()
logging.info('End Application')
