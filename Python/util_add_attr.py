#!/opt/csw/bin/python3

""""
This utility will add an attribute to the attributes table.
"""

import Datastore
from lib import my_env

# Initialize Environment
projectname = "mowdr"
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname, __file__)
my_log = my_env.init_loghandler(config, modulename)
my_log.info('Start Application')
ds = Datastore.Datastore(config)
params = dict(
    attribute="Bijsluiter",
    od_field="Bijsluiter",
    action="Extra",
    source="Dataroom",
    target="Dataset"
)
ds.insert_attribute(**params)
