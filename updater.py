import time
import subprocess
from requests import get
import json
from dotenv import load_dotenv
import os

load_dotenv()
SLEEP_TIME = int(os.getenv("SLEEP_TIME")) # in seconds

def update_route53():
    # Your domain
    IP = get('https://checkip.amazonaws.com/').content.decode('utf8')
    IP = IP.split('\n')[0]
    subprocess.run(["echo", "My IP is: ",str(IP)])
    ZONE_IDS = json.loads(os.getenv("ZONE_IDS"))
    RECORD_SETS = json.loads(os.getenv("RECORD_SETS"))
    AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
    AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
    if (len(ZONE_IDS) == len(RECORD_SETS)):
        for i in range(len(ZONE_IDS)):
            ZONE_ID = ZONE_IDS[i]
            RECORD_SET = RECORD_SETS[i]
            DATA = {
                "Changes": [
                    {
                        "Action": "UPSERT",
                        "ResourceRecordSet": {
                            "Name": RECORD_SET,
                            "Type": "A",
                            "TTL": 300,
                            "ResourceRecords": [
                                {"Value": IP}
                            ]
                        }
                    }
                ]
            }
            JSON = json.dumps(DATA)
            subprocess.run(["echo", "Updating Route53 for", RECORD_SET, "with IP", IP])
            subprocess.run(["aws", "configure", "set",
                        "AWS_ACCESS_KEY_ID", AWS_ACCESS_KEY_ID])
            subprocess.run(["aws", "configure", "set",
                        "AWS_SECRET_ACCESS_KEY", AWS_SECRET_ACCESS_KEY])
            subprocess.run(["aws", "route53", "change-resource-record-sets",
                        "--hosted-zone-id", ZONE_ID, "--change-batch", JSON])
    else:
        subprocess.run(["echo", "Error: The number of domains, zone ids, and record sets don't match."])

while True:
    subprocess.run(["echo", "Updating Route53"])
    try:
        update_route53()
    except Exception as e:
        subprocess.run(["echo", f"Error: {e}"])
    subprocess.run(["echo", f"Sleeping for {SLEEP_TIME} seconds..."])
    time.sleep(SLEEP_TIME) # in seconds
