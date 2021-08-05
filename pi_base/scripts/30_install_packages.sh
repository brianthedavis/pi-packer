#!/bin/bash
#================================================================================
#   pi base image config script
#
#================================================================================

set -x
set -e
 
function banner(){ time=`date +"%Y-%m-%d %H:%M:%S"`; printf "$time | "; printf '=%.0s' {1..40}; printf "[ ${1} ]"; printf '=%.0s' {1..40}; echo; }

date
banner "apt-get update"
apt-get update

# If TEST_BUILD is set to 1 in the packer.json file, this step will largely be skipped for the sake of a test build
# It's not meant at all for production - just to speed up test iterations
if [[ "$TEST_BUILD" == "1" ]]; then 
    echo "TEST BUILD MODE ENABLED - SKIPPING PACKAGE INSTALL" 

    # apt-get install XXX
    echo "EXITING INSTALL NOW FOR FAST BUILD"
    exit 0
fi


set +e
# The dist-upgrade occasionally fails; rather than bailing out of the packer build, just try it again....
banner "apt-get dist-upgrade"

RETRY_COUNT=5
DELAY=5
retVal=255
while (( $retVal > 0 && RETRY_COUNT > 0)); do
  time=`date +"%Y-%m-%dT%H:%M:%S"`
  apt-get dist-upgrade --yes  
  retVal=$?
  if (( $retVal > 0 )); then
    echo "[$time] Failed to execute command.  Waiting $DELAY seconds before retrying..."
    sleep $DELAY;
    DELAY=$((DELAY + 1)) # Add a backoff timer
    RETRY_COUNT=$((RETRY_COUNT - 1)) # Knock one off the retry count
    if (( $RETRY_COUNT == 0 )); then
       echo "Retry limit reached.  Failed to execute command"
    fi
  fi
done
banner "apt-get update"

set -e
apt-get update
banner "apt-get install"

apt-get install --yes curl dnsutils expat git git-core git-man iproute2 iptables iputils-ping mpc \
    nmon expat libexpat1-dev sendemail sysstat vim python-dev python-pip bootlogd python3-pip libxml2-dev \
    libxslt1-dev  secure-delete wakeonlan ntfs-3g nmap autofs hdparm util-linux lsof screen libyaml-dev \
    jq debsums iperf3 python3-gpiozero

# dhclient is crap....delete it
apt-get remove --yes isc-dhcp-client 

banner "pip install"
pip install --upgrade setuptools pip

# Required for ambient temp monitor
pip install requests
pip3 install beautifulsoup4 lxml RPi.GPIO pyyaml boto3 python-mpd2

# Install the AWS CLI - most recent ##########################################
banner "aws cli installation"
# Don't install using apt-get .... if so, do an apt-get autoremove awscli
pip3 install --upgrade awscli

mkdir -p /home/pi/.aws
cat > /home/pi/.aws/config <<EOF
[default]
region = us-west-1
output=json
s3 =
    signature_version = s3v4
[profile local]
region = us-east-1
EOF
chown pi:pi -R /home/pi/.aws
echo "**** You must copy your personal AWS credentials to ~/.aws/credentials  ****"
echo "**** and run cp -R /home/pi/.aws /root"


banner "cpan configuration"
##########
# install perl modules (this will give an interactive prompt to configure)
(echo y;echo o conf prerequisites_policy follow;echo o conf commit)|cpan


df -kh


