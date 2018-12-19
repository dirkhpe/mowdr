"""
Script to capture indicator filezwaarte - nieuwe berekening from verkeersindicatoren
"""

import json
import requests
from lib import my_env

locations = my_env.locations
dagdeel = my_env.dagdeel
dagtype = my_env.dagtype
aggregatieniveau = my_env.aggregatieniveau
voertuigklasse = my_env.voertuigklasse
wegcategorie = my_env.wegcategorie

url_starter = "http://indicatoren.verkeerscentrum.be/vc.indicators.web.gui/filezwaarteIndicator/tableData?criteria="
req_dict = dict(
    ra_id=aggregatieniveau["invloedsgebied"],
    dagtype_id=dagtype["weekdag"],
    voertuigklasse=voertuigklasse["alle"],
    wcgroep_id=wegcategorie["hoofdrijbaan"],
    tableType="month",
    # yearStartYear=2015,
    # yearEndYear=2017,
    monthStartYear=2018,
    monthEndYear=2019,
    startMonth=10,
    endMonth=1,
    locations=[str(locations[x]) for x in locations]
)
req_dict["dagdeel_id"] = dagdeel["am"]
req_str = json.dumps(req_dict)
url = "{url_starter}{req_str}".format(url_starter=url_starter, req_str=req_str)
print(url)
res = requests.get(url)
rows = res.json()["rows"]
for row in rows:
    print(row["values"])
