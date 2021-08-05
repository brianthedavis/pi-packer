#!/bin/bash
#  
# Check to see if the image has been resized properly

function banner(){ time=`date +"%Y-%m-%d %H:%M:%S"`; printf "$time | "; printf '=%.0s' {1..40}; printf "[ ${1} ]"; printf '=%.0s' {1..40}; echo; }

banner "Partition sizing"
df -kh

CORRECT_SIZE=$( df -kh / | grep -c 3.7 )
if (( CORRECT_SIZE > 0 )); then
    echo "Partition was correctly resized"
else
    echo "ERROR: Partition not sized correctly"
    exit 1
fi
