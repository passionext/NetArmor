Nginx Observability Stack: Loki, Promtail, and Grafana

This repository contains a complete, containerized laboratory to demonstrate how to implement modern log monitoring and observability. It uses Nginx as a Load Balancer, formats the access logs in JSON, and ships them to Grafana using the Loki and Promtail pipeline.
🏗️ Architecture Overview

This project follows the "One Process, One Container" philosophy. Here is how the components interact:

    Nginx Load Balancer (nginx-lb): Receives HTTP traffic on port 80 and proxies it to the backend web app. It is configured to write custom JSON access logs to a shared volume.

    Backend Web App (webapp): A simple Nginx demo application serving as the backend target.

    Promtail: The log collector. It mounts the same shared volume as the Load Balancer, reads the JSON log files in real-time, and pushes them to Loki.

    Loki: The log database. It receives, indexes (by labels like job="nginx"), and stores the logs securely.

    Grafana: The visualization layer. It queries Loki to build dashboards and analyze traffic.

📂 Project Structure

You will need three main files in your root directory to run this stack:

    docker-compose.yml: The blueprint that orchestrates all the containers, volumes, and networks.

    nginx.conf: The configuration file for the Load Balancer, defining the JSON log format and the proxy rules.

    promtail-config.yml: The configuration file telling Promtail where to find the logs and where to send them.

🚀 How to Run the Lab
Prerequisites

Make sure you have Docker and Docker Compose installed on your machine (e.g., Debian/Ubuntu).
Step 1: Start the Stack

Clone the repository, navigate to the folder containing your files, and run:
Bash

docker compose up -d

This will download the necessary images and start all 5 containers in the background.
Step 2: Generate Traffic

To create some logs, you need to simulate user traffic. Run this command in your terminal to hit the Load Balancer 10 times:
Bash

for i in {1..10}; do curl http://localhost:80; done

Step 3: Access Grafana

    Open your web browser and navigate to http://localhost:3000.

    Log in with the default credentials:

        Username: admin

        Password: admin (You will be prompted to change it).

🔍 How to View the Logs in Grafana

Once inside Grafana, you need to query the logs:

    Go to Connections > Data Sources and add Loki.

    Set the URL to http://loki:3100 and click Save & Test. You should see a green success message.

    In the left menu, click on the Explore icon (the compass).

    Select Loki from the dropdown menu at the top left.

    In the query bar, type the following LogQL query to fetch and format the JSON logs:
    Snippet di codice

    {job="nginx"} | json

    Crucial Step: Ensure your time picker (top right) is set to "Last 1 hour" or "Last 24 hours" to match your server's timezone, then click Run Query.

🧠 How the "Magic" Works (Deep Dive)
The Shared Volume Strategy

A common pitfall in Docker is that containers are isolated. If Nginx writes a log file, Promtail cannot see it by default. We solve this using a Named Volume in the docker-compose.yml:
YAML

volumes:
  - nginx-logs:/var/log/nginx  # Nginx writes here
  - nginx-logs:/var/log/nginx:ro # Promtail reads from here (Read-Only)

This creates a shared virtual folder. Nginx slips the log file into the folder, and Promtail reads it simultaneously without breaking container isolation.
The JSON Log Format

In the nginx.conf, we use log_format json_combined escape=json.
Instead of plain text, Nginx writes logs like this: {"status": "200", "remote_addr": "192.168.1.5", ...}.
This is incredibly powerful because Grafana can automatically parse JSON, allowing you to instantly build graphs based on specific fields (e.g., charting the status code or tracking the request_time).
Wildcard Log Scraping

In promtail-config.yml, we use a wildcard __path__: /var/log/nginx/*.log. This prevents naming mismatches. Whether Nginx writes to access.log, my_access.log, or web_access.log, Promtail will find it and ship it to Loki.
🛠️ Troubleshooting

    No logs in Grafana? * Check if Nginx actually created the file: docker exec nginx-lb ls -lh /var/log/nginx

        Ensure the time range in Grafana Explore is wide enough (e.g., "Last 2 days") in case your host machine's clock is out of sync with the containers.

    Containers cannot talk to each other?

        Verify that all services are attached to the same custom bridge network (backend-net). Docker uses this network to resolve container names (like http://loki:3100) to internal IPs.
