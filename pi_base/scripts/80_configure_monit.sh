#!/bin/bash
#================================================================================
#   Pi - run as root
#
#================================================================================

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${DIR}/host_config"

apt-get install --yes monit

# Make monit sleep on startup....
sed -i.bak -E "s/#(\s+with start delay)/\1/" /etc/monit/monitrc

## TODO: fix the sourcing of the host config since this pathing won't work in packer

# CONFIGURE monit
MONIT_ROOT=/etc/monit/conf.d

mkdir -p ${MONIT_ROOT}
cd ${MONIT_ROOT}
rm -rf ${MONIT_ROOT}/*
monit_config_root=${homedir}/scripts/config/monit

if [[ "$monit_configs" == "" ]]; then echo "monit_configs must be defined.  check ./host_config or packer json"  1>&2; exit 1; fi
echo "Monit configs: $monit_configs"

for conf in ${monit_configs}
do
  echo "Monitoring ${conf}..."
  ln -s ${monit_config_root}/$conf /etc/monit/conf.d/$conf
done

echo "Restarting monit..."
systemctl restart monit

echo "Monit restarted"

