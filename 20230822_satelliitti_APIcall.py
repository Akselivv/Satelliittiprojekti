from oauthlib.oauth2 import BackendApplicationClient
from requests_oauthlib import OAuth2Session

import json
import os

# Read client credentials
os.chdir("//home.org.aalto.fi/valivia1/data/Documents/GitHub/Satelliittiprojekti")
with open("client_id_secret.txt", "r") as id_secret:
    lines = id_secret.readlines()
    print(lines)

secrets = []

for l in lines:
    as_list = l.split(", ")
    secrets.append(as_list[0].replace("\n", ""))

# Your client credentials
client_id = secrets[0]
client_secret = secrets[1]

# Create a session
client = BackendApplicationClient(client_id=client_id)
oauth = OAuth2Session(client=client)

# Get token for the session
token = oauth.fetch_token(token_url='https://services.sentinel-hub.com/oauth/token',
                          client_secret=client_secret)

# All requests using this session will have an access token automatically added
resp = oauth.get("https://services.sentinel-hub.com/oauth/tokeninfo")
print(resp.content)
print(token)

evalscript = r.evalScriptFromR

stats_request = {
  "input": {
   "bounds": {
      "bbox": r.coordInputList,
    "properties": {
        "crs": "http://www.opengis.net/def/crs/EPSG/0/32633"
        }
    },
    "data": [
      {
        "type": "sentinel-2-l2a",
        "dataFilter": {
            "mosaickingOrder": "leastCC"
        }
      }
    ]
  },
  "aggregation": {
    "timeRange": {
            "from": "2018-01-01T00:00:00Z",
            "to": "2023-08-21T00:00:00Z"
      },
    "aggregationInterval": {
        "of": "P10D"
    },
    "evalscript": evalscript,
    "resx": 10,
    "resy": 10
  }
}

headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json'
}
url = "https://services.sentinel-hub.com/api/v1/statistics"

response = oauth.request("POST", url=url , headers=headers, json=stats_request)
sh_statistics = response.json()
print(sh_statistics)

#with open('data45.json', 'w', encoding='utf-8') as f:
#    json.dump(sh_statistics, f, ensure_ascii=False, indent=4)
