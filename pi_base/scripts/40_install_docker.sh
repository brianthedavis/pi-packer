#!/bin/bash
# Expected variables:
#    os_user

set -e 

if [[ "${os_user}" == "" ]]; then
    export os_user=pi
    echo "os_user variable not set - defaulting to ${os_user}"
fi

INSTALL_DOCKER=/tmp/get-docker.sh
curl -fsSL https://get.docker.com -o ${INSTALL_DOCKER}

sh ${INSTALL_DOCKER}

gpasswd -a ${os_user} docker

# New way to install docker-compose
# https://dev.to/rohansawant/installing-docker-and-docker-compose-on-the-raspberry-pi-in-5-simple-steps-3mgl
apt-get install -y libffi-dev libssl-dev python3 python3-pip
apt-get remove -y python-configparser
pip3 install docker-compose

echo "** YOU MUST LOG OUT AND LOG IN TO ENABLE DOCKER COMMAND WITHOUT ROOT **"

