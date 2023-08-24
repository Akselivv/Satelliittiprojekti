from oauthlib.oauth2 import BackendApplicationClient
from requests_oauthlib import OAuth2Session

import json

# Your client credentials
client_id = '5876fc78-d265-47e0-9be3-480215b785fc'
client_secret = 'Qv:+#co:JreWlDIJ:qkODt}9yyRIT+{#Gw3;Z-T7'

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

evalscript = """
//VERSION=3
function setup() {
  return {
    input: [{
      bands: [
        "B04",
        "B08",
        "SCL",
        "CLM",
        "dataMask"
      ]
    }],
    output: [
      {
        id: "data",
        bands: 1
      },
      {
        id: "dataMask",
        bands: 1
      }]
  }
}

function evaluatePixel(samples) {

    let ndvi = -Math.log(0.371 + 1.5 * (samples.B08 - samples.B04) / (samples.B08 + samples.B04 + 0.5)) / 2.4
    var noWaterMask = 1
    if (samples.SCL == 6 ){
        noWaterMask = 0
    }

    var noCloudMask = 1
    if (samples.CLM == 1) {
        noCloudMask = 0
    }

    return {
        data: [ndvi],
        // Exclude nodata pixels, pixels where ndvi is not defined and water pixels from statistics:
        dataMask: [samples.dataMask * noWaterMask * noCloudMask]
    }
}
"""

stats_request = {
  "input": {
   "bounds": {
      "bbox": [
        614159.170708217, 
        287855.644390796, 
        614133.555587783, 
        287802.108639204
        ],
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

with open('data45.json', 'w', encoding='utf-8') as f:
    json.dump(sh_statistics, f, ensure_ascii=False, indent=4)
