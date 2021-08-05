#!/bin/bash
# Install the node_exporter (on every machine)
set -e

# RUN AS ROOT!
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root" 1>&2; exit 1; fi


TMP=/tmp/prometheus
mkdir -p $TMP
cd $TMP

# Binaries can be downloaded for armv7 here: https://prometheus.io/download/
# Node exporter

# Pi Zeros have ARMv6 chips, not ARMv7
if (( $( grep -c ARMv6 /proc/cpuinfo ) || "$cpu" == "ARMv6" )); then
   echo Running on ARMv6
   #URL=https://github.com/prometheus/node_exporter/releases/download/v0.15.2/node_exporter-0.15.2.linux-armv6.tar.gz
   URL=https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-armv6.tar.gz
else
   echo Running on ARMv7
   #URL=https://github.com/prometheus/node_exporter/releases/download/v0.15.2/node_exporter-0.15.2.linux-armv7.tar.gz 
   URL=https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-armv7.tar.gz
fi

curl -LO $URL

#cd $TMP/prometheus-*

# its okay if the useradd fails if the user already exists...
set +e 
# setup based on https://www.digitalocean.com/community/tutorials/how-to-install-prometheus-on-ubuntu-16-04
useradd --no-create-home --shell /bin/false node_exporter
set -e


tar xvf node_exporter-*linux-armv*.tar.gz 

cp    node_exporter-*linux-armv*/node_exporter /usr/local/bin
chown node_exporter:node_exporter               /usr/local/bin/node_exporter

rm -rf node_exporter-*.gz node_exporter-*.linux-armv*

cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

#If you ever need to override the default list of collectors, you can use the --collectors.enabled flag, like:
#ExecStart=/usr/local/bin/node_exporter --collectors.enabled meminfo,loadavg,filesystem

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable node_exporter

systemctl start node_exporter
systemctl status node_exporter
