#!/bin/bash
#  Assign a hostname
#    Required environment variables:
#      newhost
#      homedir

set -x

function banner(){ set +x; time=`date +"%Y-%m-%d %H:%M:%S"`; printf "$time | "; printf '=%.0s' {1..40}; printf "[ ${1} ]"; printf '=%.0s' {1..40}; echo; set -x;}


if [[ "$newhost" == "" ]]; then 
	echo "Enter hostname to assign:"
	read newhost
else
	echo "Using hostname: $newhost"
fi

if [[ "${homedir}" == "" ]]; then
	homedir=/home/pi
	echo "Defaulting homedir to ${homedir}"
fi


banner "Assigning hostname: ${newhost}" ########################################################

################################################################################
#  Set Hostname
################################################################################
echo -e "\n\nNEW HOST NAME: ${newhost}"

### Set the hostname
echo ${newhost} > /etc/hostname

# Set the login banner
echo "Welcome to ${newhost}" > /etc/motd

### Set the hostname inside of /etc/hosts (in case there isn't a good dns)
echo -e "127.0.0.1\t${newhost}\n" >> /etc/hosts

### if pi-image was set, swap it out in /etc/hosts
sed -i.bak "s/pi-image/$newhost/" /etc/hosts


################################################################################
#  GIT Configuration
################################################################################
cat << GIT > ${homedir}/.gitconfig
[user]
	email = brian@${newhost}
	name = Brian Davis
[push]
	default = simple
[core]
	editor = vim
GIT
