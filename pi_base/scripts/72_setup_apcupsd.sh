#!/bin/bash
# Setup and and configure the APC UPS 
#  ENIRONMENT DEFINED VARIABLES:
#     apc_connected: must be defined in the environment as net or usb
#     homedir: /home/pi


set -e

# RUN AS ROOT!
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root" 1>&2; exit 1; fi


if [[ "${apc_connected}" == "" ]]; then echo "APC_CONNECTED must be defined.  check environment"  1>&2; exit 1; fi
echo "APC_CONNECTED: ${apc_connected}"


# https://wiki.debian.org/apcupsd

# Verify it's connected using lsusb
apt-get update
apt-get install -y apcupsd apcupsd-doc

APCDIR=/etc/apcupsd
CONFIG=${homedir}/scripts/config/apcupsd
# Link in the config file from git
mv "${APCDIR}/apcupsd.conf" "${APCDIR}/apcupsd.conf.orig"
if [[ "$APC_CONNECTED" == "usb" ]]; then 
    ln -s "${CONFIG}/apcupsd.conf" "${APCDIR}/apcupsd.conf"
else # APC_CONNECTED = net
    ln -s "${CONFIG}/apcupsd-net.conf" "${APCDIR}/apcupsd.conf"
fi


# Confirm everything works okay
# apcaccess status


# TODO:
# Add monit config
# 