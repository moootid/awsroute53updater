# AWS Route 53 Dynamic DNS Updater

This is a simple, containerized Python script that serves as a Dynamic DNS (DDNS) client for **AWS Route 53**. It periodically checks your network's public IP address. If the IP has changed, the script automatically updates one or more **A records** in your AWS Route 53 hosted zones.

This tool is perfect for anyone hosting a service (like a web server or home automation hub) on a residential internet connection with a dynamic IP address.

-----

## How It Works ⚙️

 The script runs in an infinite loop with a configurable sleep interval:

1.   It gets the current public IP address from `https://checkip.amazonaws.com/`.
2.   It compares this new IP to the last known IP address stored in memory.
3.   If the IP address has changed, it uses the AWS CLI to update the specified record sets in the corresponding Route 53 hosted zones.
4.   It sleeps for a defined period before repeating the process.

 The entire application is designed to be run within a **Docker container**, making deployment simple and consistent.

-----

## Getting Started 🚀

### Prerequisites

  * **Docker** and **Docker Compose** installed.
  * An **AWS account**.
  * An **IAM User** with programmatic access (`Access key ID` and `Secret access key`) and permissions to modify Route 53 records. A minimal IAM policy would look like this:
    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "route53:GetChange",
                    "route53:ChangeResourceRecordSets"
                ],
                "Resource": "arn:aws:route53:::hostedzone/YOUR_HOSTED_ZONE_ID"
            },
            {
                "Effect": "Allow",
                "Action": "route53:ListHostedZonesByName",
                "Resource": "*"
            }
        ]
    }
    ```
  * A **Hosted Zone** configured in AWS Route 53.

### Configuration

 The application is configured using environment variables passed from the `docker-compose.yml` file.

1.  Create a file named `.env` in the root of the project directory.
2.  Copy the contents of the example below into your `.env` file and replace the placeholder values with your own.

#### `.env` example:

```env
# [cite_start]Your AWS Route 53 Hosted Zone IDs as a JSON array. 
# Example: ["Z0123456789ABCDEFGHIJ", "Z9876543210ZYXWVUTSRQ"]
ZONE_IDS='["YOUR_ZONE_ID_HERE"]'

# [cite_start]Your AWS credentials. 
AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY_ID"
AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_ACCESS_KEY"

# [cite_start]The DNS records you want to update, as a JSON array. 
# These must correspond in order to the ZONE_IDS above.
# Example: ["home.example.com", "service.example.com"]
RECORD_SETS='["subdomain.yourdomain.com"]'

# [cite_start]The time in seconds between IP checks. 
# 86400 = 24 hours, 3600 = 1 hour, 300 = 5 minutes
SLEEP_TIME=300
```

**Note:** The `ZONE_IDS` and `RECORD_SETS` are JSON arrays. The script checks that they have the same number of elements to ensure a one-to-one mapping.

### Running the Updater

Once your `.env` file is configured, you can start the service in detached mode using Docker Compose.

```bash
docker-compose up -d
```

The container will now be running in the background. You can check its logs to ensure it's working correctly:

```bash
docker-compose logs -f
```

 You should see output indicating that the script is checking your IP and updating Route 53 if necessary.

### Using the Pre-built Docker Hub Image

 The `docker-compose.yml` is configured to use the pre-built image from Docker Hub: `lazem/awsroute53updater:latest`. You do not need to build the image yourself unless you make changes to the `updater.py` script or `Dockerfile`.

To stop the service:

```bash
docker-compose down
```