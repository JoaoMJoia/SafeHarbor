#!/bin/bash
# Update the instance
sudo yum update -y

# Install Apache (httpd) and required modules
sudo yum install -y httpd mod_ssl mod_proxy mod_proxy_http mod_headers mod_security

# Read variables from environment (set by Terraform user_data)
BACKEND_URL="${BACKEND_URL}"
LOG_NAME="${LOG_NAME:-reverse_proxy}"
LOKI_HOST="${LOKI_HOST:-}"
LOKI_DOMAIN="${LOKI_DOMAIN:-}"
ENABLE_PROMTAIL="${ENABLE_PROMTAIL:-false}"

# Create the reverse proxy configuration
cat >/etc/httpd/conf.d/reverse-proxy.conf <<EOF
<VirtualHost *:80>
    ServerName ${BACKEND_URL}

    # --- LOGGING CONFIGURATION BEFORE PROXY ---
    LogFormat "%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" \"%{X-Forwarded-For}i\" \"%{X-Real-IP}i\" \"%{REMOTE_ADDR}e\"" debug1
    CustomLog /var/log/httpd/${LOG_NAME}_debug1.log debug1

    # --- SECURITY & HEADER SANITY ---
    ProxyRequests Off
    ProxyPreserveHost On

    # --- CACHING ---
    <IfModule mod_setenvif.c>
        SetEnvIf Cache-Control "(.*)" http_cache_control=$1
    </IfModule>

    # --- REDIRECT INSECURE REQUESTS (ONLY FOR BACKEND) ---
    RewriteEngine On
    RewriteCond %{HTTP:X-Forwarded-Proto} =http
    RewriteRule .* https://%{HTTP:Host}%{REQUEST_URI} [L,R=permanent]

    # --- SSL SETTINGS FOR PROXY BACKEND ---
    # Enable SSL proxy engine
    SSLProxyEngine on

    # Disable SSL certificate verification for the backend
    SSLProxyCheckPeerCN off
    SSLProxyCheckPeerName off

    # --- REVERSE PROXY CONFIGURATION ---
    # /app path goes to the app path of the application
    ProxyPass "/app" "${BACKEND_URL}/app"
    ProxyPassReverse "/app" "${BACKEND_URL}/app"

    # / path goes to the root of the application
    ProxyPass "/" "${BACKEND_URL}/"
    ProxyPassReverse "/" "${BACKEND_URL}/"

    # --- Headers manipulation ---
    # This removes Server header from proxied responses
    Header always unset Server
    Header always set Server ""

    # This removes X-Powered-By header from upstream responses
    # After our manipulation, WPEngine adds this header to responses
    # because is a restricted header
    Header always unset X-Powered-By
    Header always set X-Powered-By ""

    # --- ModSecurity configuration ---
    # Disable ModSecurity for login page
    <Location /app/sign-in>
        SecRuleEngine Off
    </Location>

    # --- LOGGING CONFIGURATION AFTER PROXY ---
    LogFormat "%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" \"%{X-Forwarded-For}i\" \"%{X-Real-IP}i\" \"%{REMOTE_ADDR}e\"" debug
    CustomLog /var/log/httpd/${LOG_NAME}_debug.log debug

    ErrorLog /var/log/httpd/${LOG_NAME}_error.log
    CustomLog /var/log/httpd/${LOG_NAME}_access.log combined
</VirtualHost>
EOF

# Check the syntax of the Apache configuration file
sudo httpd -t

# Start and enable Apache (httpd) to start on boot
sudo systemctl start httpd
sudo systemctl enable httpd

# Ensure proper permissions for firewall (Amazon Linux AMI uses firewalld)
# Opening port 80 (HTTP) for incoming connections
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent 2>/dev/null || true
sudo firewall-cmd --reload 2>/dev/null || true

echo "Apache2 with Reverse Proxy Setup Complete."

# Install Promtail if enabled
if [ "$ENABLE_PROMTAIL" = "true" ] && [ -n "$LOKI_HOST" ] && [ -n "$LOKI_DOMAIN" ]; then
    echo "Installing Promtail for log shipping..."
    
    # Install Promtail
    wget -q https://github.com/grafana/loki/releases/download/v2.9.2/promtail-linux-amd64.zip
    unzip -q promtail-linux-amd64.zip
    sudo mv promtail-linux-amd64 /usr/local/bin/promtail
    sudo chmod +x /usr/local/bin/promtail

    # Install gettext package which provides envsubst
    sudo yum install -y gettext

    # Ensure LOKI_HOST is loaded from environment
    echo "Current LOKI_HOST value: $LOKI_HOST"

    # Create Promtail config directory
    sudo mkdir -p /etc/promtail

    # Create Promtail config file
    echo "Creating Promtail config with LOKI_HOST=$LOKI_HOST"
    cat <<EOF | envsubst | sudo tee /etc/promtail/promtail-config.yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: https://${LOKI_HOST}.${LOKI_DOMAIN}/loki/api/v1/push

scrape_configs:
  - job_name: "${LOG_NAME}-httpd-logs"
    static_configs:
      - targets:
          - localhost
        labels:
          job: "${LOG_NAME}-httpd-logs"
          log_type: "access"
          service: "${LOG_NAME}"
          __path__: /var/log/httpd/${LOG_NAME}_access.log

      - targets:
          - localhost
        labels:
          job: "${LOG_NAME}-httpd-logs"
          log_type: "error"
          service: "${LOG_NAME}"
          __path__: /var/log/httpd/${LOG_NAME}_error.log
    pipeline_stages:
      - regex:
          expression: '^(?P<ip>\S+) (?P<ident>\S+) (?P<user>\S+) \[(?P<timestamp>[\w:/]+\s[+\-]\d{4})\] "(?P<method>\S+) (?P<path>\S+) (?P<protocol>\S+)" (?P<status>\d{3}) (?P<size>\d+) "(?P<referer>[^"]*)" "(?P<useragent>[^"]*)"'
      - timestamp:
          source: timestamp
          format: "02/Jan/2006:15:04:05 -0700"
      - labels:
          status:
          method:
          path:
          protocol:
          useragent:
      - metrics:
          request_size:
            type: Histogram
            description: "Request size in bytes"
            source: size
            config:
              buckets: [100, 1000, 10000, 100000, 1000000]
          status_code:
            type: Counter
            description: "Total number of status codes"
            source: status
            config:
              action: inc
EOF

    # Verify the config file content
    echo "Verifying Promtail config content:"
    cat /etc/promtail/promtail-config.yaml

    # Create systemd service file
    cat <<EOF | sudo tee /etc/systemd/system/promtail.service
[Unit]
Description=Promtail
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/promtail -config.file /etc/promtail/promtail-config.yaml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    # Start Promtail service
    sudo systemctl daemon-reload
    sudo systemctl start promtail
    sudo systemctl enable promtail

    # Clean up
    rm -f promtail-linux-amd64.zip
    
    echo "Promtail installation and configuration complete."
fi
