#!/bin/bash
# Fix file permissions for files that were copied by the provisioner

HOMEDIR=/home/$os_user
echo "Correcting permissions in ${homedir}"
chown ${os_user}:${os_user} -R ${homedir}
