"""
This script will check Open Data URLs. It will read the URLs from indicatorfiches.xml as calculated by APEX and
verify if the page exists.
"""

import argparse
import xml.etree.ElementTree as eT
from lib import my_env
from urllib.request import urlopen
from urllib.error import HTTPError

# Initialize Environment
projectname = "mowdr"
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname, __file__)
my_log = my_env.init_loghandler(config, modulename)
my_log.info('Start Application')

parser = argparse.ArgumentParser(description="Check OD URLs.")
parser.add_argument("-f", "--fileName", type=str, required=True,
                    help="Please provide full path name for indicatorfiches.xml.")

args = parser.parse_args()
my_log.info("Arguments: {a}".format(a=args))

tree = eT.parse(args.fileName)
root = tree.getroot()
cnt = ok = nok = 0
for url in root.iter('url_od_portal'):
    cnt += 1
    try:
        resp = urlopen(url.text)
    except HTTPError as e:
        print("URL: {url} - Error: {c}, {m}".format(url=url.text, c=e.code, m=e.reason))
        nok += 1
    else:
        print("URL: {url} - Status: {s}".format(url=url.text, s=resp.status))
        ok += 1
print("{cnt} URLs checked, {ok} OK, {nok} Not OK".format(cnt=cnt, ok=ok, nok=nok))
