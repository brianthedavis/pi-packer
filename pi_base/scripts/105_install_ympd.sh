#!/bin/bash
# Install ympd as a system service on this pi running at 8080
# Run as root
#
#  release should be defined from packer.json
set -e
#set -x
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root" 1>&2; exit 1; fi

# Get the release name (i.e. buster)
if [[ "${release}" == "" ]]; then
  release=$( lsb_release -a | grep Codename | awk '{ print $2 }' )
else
  echo "release variable passed in as ${release}"
fi

YMPD=/tmp/ympd-${RELEASE}-latest.tgz
URL=http://pi/share/sw/ympd-${release}-latest.tgz

## NOTE
# The stretch version of Debian has a different version of libssl installed. Youll need
# the following commands to replace the binary 
###   scp pi:/data/sw/ympd_20181214_v1.3.0-76-g5424a7d-libssl.tgz .
###   tar xvfz ympd_20181214_v1.3.0-76-g5424a7d-libssl.tgz 
###   sudo cp ympd /usr/bin/ympd/ympd

echo "Grabbing ympd from pi at ${URL}"
curl ${URL} > $YMPD


mkdir -p /usr/bin/ympd
tar xvfz $YMPD -C /usr/bin/ympd

cat > /etc/systemd/system/ympd.service <<EOF
[Unit]
Description=ympd MPD Client

[Service]
ExecStart=/usr/bin/ympd/ympd
WorkingDirectory=/usr/bin/ympd
Restart=always
Type=simple
User=pi
Group=pi

[Install]
WantedBy=multi-user.target
EOF
set +e

systemctl daemon-reload
systemctl enable ympd

# if it's running, restart it
systemctl stop ympd

systemctl start ympd # Start on port 8080

# # Add the crontab entry to reload the central database regularly
# if [[ "$( grep -c update_central_playlists /etc/crontab )" == "0" ]]; then
#   echo "15 1   * * *   pi      /home/pi/scripts/update_central_playlists.sh >> /var/log/playlist_update.log 2>&1" >> /etc/crontab
# fi
set -e

touch /var/log/playlist_update.log
chmod 666 /var/log/playlist_update.log

touch /var/log/playlist_download.log
chmod 666 /var/log/playlist_download.log 

# If we're on the pi, then /data/mpd contains all of our mpd information...
if [[ -d /data/mpd ]]; then
  if [[ ! -L /var/lib/mpd ]]; then
    echo "Linking /var/lib/mpd to /data/mpd"
    # link the mpd directory
    set +e # these commands will fail in a packer image so let them fail....
    systemctl stop mpd
    set -e
    mv /var/lib/mpd /var/lib/mpd.orig
    ln -s /data/mpd /var/lib/mpd
    chown mpd:audio -R /var/lib/mpd/*
    chown mpd:audio -R /var/lib/mpd/.
    usermod -a -G audio pi
    chmod g+rw -R /var/lib/mpd/*
    set +e
    systemctl start mpd
    set -e
  else
    echo "/var/lib/mpd is already a link....skipping re-link"
  fi
else
  mkdir -p /var/lib/mpd/music/sync
  chmod gou+rw -R /var/lib/mpd/*
fi
