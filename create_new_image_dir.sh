#!/bin/bash
# Create a new image directory
# Usage: 
#   create_new_image.sh <dirname>
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ "$1" == "" ]]; then
    echo "You must specify an image name path to create."
    exit 1;
fi

DEST=$1
mkdir "${DIR}/${DEST}"
cd "${DIR}/${DEST}"
ln -s "../pi_base/scripts" "${DIR}/${DEST}/scripts"

SETUP_PATH="../../setup/${DEST}"
if [[ -d "${SETUP_PATH}" ]]; then
    ln -s "${SETUP_PATH}" "${DIR}/${DEST}/setup"
fi

ln -s ../pi_base/build
ln -s ../pi_base/clean_images.sh
cp ../pi_base/pi_base.json ./${DEST}.json
sed -i.bak "s/pi-image/${DEST}/g" ./${DEST}.json
rm ./${DEST}.json.bak

echo -e "\n\nNew template directory created at ${DIR}/${DEST}"