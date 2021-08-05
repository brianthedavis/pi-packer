#!/bin/bash
#================================================================================
#   Copy any files in the setup path over if they exists
#
#================================================================================
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root" 1>&2; exit 1; fi

# Set the homedir path
if [[ "${homedir}" == "" ]]; then
   DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
   echo "homedir not defined; defaulting to: $DIR"
   CFG_PATH=${DIR}

else
   DIR="${homedir}/scripts/${newhost}/setup"
   CFG_PATH=${homedir}/scripts/setup/${newhost}
fi

# Packer running in Docker's paths are weird and not necessarily mounted in the packer image - just copy from the scripts path
# since it's copied over before we run
if [[ -e "${CFG_PATH}/crontab" ]]; then 
    echo "Copying ${CFG_PATH}/crontab to /etc/crontab..."
    cp "${CFG_PATH}/crontab" /etc/crontab
fi

# echo "Copying any .service files to /etc/systemd/system"
# cp "${CFG_PATH}/*.service" /etc/systemd/system

