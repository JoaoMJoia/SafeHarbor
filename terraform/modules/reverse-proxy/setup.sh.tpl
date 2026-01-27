#!/bin/bash
# Update the instance
sudo yum update -y

# Install Apache (httpd) and required modules
sudo yum install -y httpd mod_ssl mod_proxy mod_proxy_http mod_proxy_http2 mod_headers mod_rewrite mod_security

# Create the reverse proxy configuration
cat >/etc/httpd/conf.d/reverse-proxy.conf <<APACHE_EOF
<VirtualHost *:80>
    ServerName ${backend_url}

    # --- LOGGING CONFIGURATION ---
    LogFormat "%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" \"%{X-Forwarded-For}i\" \"%{X-Real-IP}i\" \"%{REMOTE_ADDR}e\"" combined_with_headers
    CustomLog /var/log/httpd/${log_name}_access.log combined_with_headers
    ErrorLog /var/log/httpd/${log_name}_error.log

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
%{ for rule in reverse_proxy_rules ~}
    ProxyPass "${rule.path}" "${rule.backend}"
%{ if rule.preserve != false ~}
    ProxyPassReverse "${rule.path}" "${rule.backend}"
%{ endif ~}
%{ endfor ~}

    # --- Headers manipulation ---
    # This removes Server header from proxied responses
    Header always unset Server
    Header always set Server ""

    # This removes X-Powered-By header from upstream responses
    Header always unset X-Powered-By
    Header always set X-Powered-By ""

    # --- ModSecurity configuration ---
    # Disable ModSecurity for login page (if exists)
    <LocationMatch "/sign-in|/login">
        SecRuleEngine Off
    </LocationMatch>
</VirtualHost>
APACHE_EOF

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
%{ if enable_promtail && loki_host != "" && loki_domain != "" ~}
echo "Installing Promtail for log shipping..."

# Install Promtail
wget -q https://github.com/grafana/loki/releases/download/v2.9.2/promtail-linux-amd64.zip
unzip -q promtail-linux-amd64.zip
sudo mv promtail-linux-amd64 /usr/local/bin/promtail
sudo chmod +x /usr/local/bin/promtail

# Install gettext package which provides envsubst
sudo yum install -y gettext

# Create Promtail config directory
sudo mkdir -p /etc/promtail

# Create Promtail config file
cat <<PROMTAIL_EOF | sudo tee /etc/promtail/promtail-config.yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: https://${loki_host}.${loki_domain}/loki/api/v1/push

scrape_configs:
  - job_name: "${log_name}-httpd-logs"
    static_configs:
      - targets:
          - localhost
        labels:
          job: "${log_name}-httpd-logs"
          log_type: "access"
          service: "${log_name}"
          __path__: /var/log/httpd/${log_name}_access.log

      - targets:
          - localhost
        labels:
          job: "${log_name}-httpd-logs"
          log_type: "error"
          service: "${log_name}"
          __path__: /var/log/httpd/${log_name}_error.log
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
PROMTAIL_EOF

# Create systemd service file
cat <<SYSTEMD_EOF | sudo tee /etc/systemd/system/promtail.service
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
SYSTEMD_EOF

# Start Promtail service
sudo systemctl daemon-reload
sudo systemctl start promtail
sudo systemctl enable promtail

# Clean up
rm -f promtail-linux-amd64.zip

echo "Promtail installation and configuration complete."
%{ endif ~}
