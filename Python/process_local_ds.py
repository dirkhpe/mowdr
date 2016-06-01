#!/opt/csw/bin/python3

import json
import logging
from lib import my_env


def get_local_ds(filepath):
    """
    This method will read the dataset info that is locally available.
    :param filepath:
    :return:
    """
    f = open(filepath)
    res = json.load(f)
    print(res["name"])
    print(res["title"])
    print(res["resources"][0]["package_id"])
    return


# Get ini-file first.
projectname = 'mowdr'
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname, __file__)
# Now configure logfile
my_env.init_logfile(config, modulename)
logging.info('Start Application')
logdir = config['Main']['logdir']
# local_file = 'C:\Temp\Log\drmow-ind011.json'
local_file = 'C:\Temp\Log\zwinpolders.json'
get_local_ds(local_file)
logging.info('End Application')
