__author__ = 'delahayd'
from urllib.parse import quote
# from urllib.request import pathname2url
import httplib2
from Ftp_Handler import Ftp_Handler
from PublicCognos import PublicCognos
from FileHandler import FileHandler
import logging


def check_if_cognos_report_exists(indicator):
    encoded_name = quote(indicator, safe='/()')
    h = httplib2.Http()
    url = "http://vobippubliek.vlaanderen.be/cognos10/cgi-bin/cognosisapi.dll?b_action=cognosViewer&ui.action=run&ui.object=%2fcontent%2ffolder%5b%40name%3d%271M%20-%20Mobiliteit%20en%20Openbare%20Werken%20(MOW)%27%5d%2ffolder%5b%40name%3d%27Dataroom%27%5d%2ffolder%5b%40name%3d%27Standaardrapporten%27%5d%2ffolder%5b%40name%3d%27{0}%27%5d%2freport%5b%40name%3d%27{0}%27%5d".format(encoded_name)
    print("Generated URL: " + url)
    resp = h.request(url)
    try:
        status = str(resp[0]['content-id'])
        print("Encoded: " + status)
    except KeyError as err:
        return True
    return False


fh = FileHandler("mowdr")
logfilename = fh.get_logfilename()
config = fh.get_inifile("mowdr")
logging.basicConfig(format='%(asctime)s:%(levelname)s:%(module)s:%(funcName)s:%(lineno)d:%(message)s',
                    datefmt='%d/%m/%Y %H:%M:%S', filename=logfilename, level=logging.DEBUG)
logging.info('\n\n\nStart Application')
pc_url = PublicCognos()
ftp = Ftp_Handler(config)
report_name = 'filezwaarte op het hoofdwegennet'
print('Check "' + report_name + '": ' + str(pc_url.check_if_cognos_report_exists(report_name)))
print('Check "' + report_name + '": ' + str(check_if_cognos_report_exists(report_name)))

report_name = 'filezwaarte op het yolotanker'
print('Check "' + report_name + '": ' + str(pc_url.check_if_cognos_report_exists(report_name)))

report_name = 'voertuigenpark (de lijn)'
print('Check "' + report_name + '": ' + str(pc_url.check_if_cognos_report_exists(report_name)))

report_name = 'verdeling van verplaatsingen volgens verplaatsingsmotief'
print('Check "' + report_name + '": ' + str(pc_url.check_if_cognos_report_exists(report_name)))

if pc_url.check_if_cognos_report_exists(report_name):
    pc_url.redirect2cognos(3, config)
logging.info('End Application')