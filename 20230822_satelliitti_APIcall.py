from oauthlib.oauth2 import BackendApplicationClient
from requests_oauthlib import OAuth2Session

import json

# Your client credentials
client_id = '<your-client-id>'
client_secret = '<your-client-secret>'

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
    let ndvi = (samples.B08 - samples.B04)/(samples.B08 + samples.B04)

    var validNDVIMask = 1
    if (samples.B08 + samples.B04 == 0 ){
        validNDVIMask = 0
    }

    var noWaterMask = 1
    if (samples.SCL == 6 ){
        noWaterMask = 0
    }

    return {
        data: [ndvi],
        // Exclude nodata pixels, pixels where ndvi is not defined and water pixels from statistics:
        dataMask: [samples.dataMask * validNDVIMask * noWaterMask]
    }
}
"""

stats_request = {
  "input": {
   "bounds": {
      "bbox": [
        290230.910000,
        624138.290000,
        290276.820000,
        624180.420000
        ],
    "properties": {
        "crs": "http://www.opengis.net/def/crs/EPSG/0/32633"
        }
    },
    "data": [
      {
        "type": "sentinel-2-l2a",
        "dataFilter": {
            "mosaickingOrder": "leastRecent"
        }
      }
    ]
  },
  "aggregation": {
    "timeRange": {
            "from": "2018-01-01T00:00:00Z",
            "to": "2021-01-01T00:00:00Z"
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

with open('data10.json', 'w', encoding='utf-8') as f:
    json.dump(sh_statistics, f, ensure_ascii=False, indent=4)
