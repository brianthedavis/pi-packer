#!/bin/bash

# If TEST_BUILD is set to 1 in the packer.json file, this step will largely be skipped for the sake of a test build
# It's not meant at all for production - just to speed up test iterations
if [[ "$TEST_BUILD" == "1" ]]; then 
    echo "TEST BUILD MODE ENABLED - SKIPPING IMAGE ZERO" 
    exit 0
fi


echo "Cleaning up any residual packages....."
df -kh
# Do any necessary cleanup
apt-get install -y sfill
apt -y autoclean
apt -y autoremove
apt-get -y clean
echo -e "\n\n"

echo "Zeroing free space..."



sfill -v -l -l -z /

