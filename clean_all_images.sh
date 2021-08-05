#!/bin/bash
# Delete all images in output-arm-image
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "${DIR}"
find . | grep output-arm-image | grep img
echo -e "\n"
read -p "Delete all images (y/N)? " confirm; if [[ "$confirm" != "Y" && "$confirm" != "y" ]]; then exit; fi;

echo "proceeding..."
rm */output-arm-image/*.img
rm */output-arm-image/*.img.zip
rm */packer_cache/*

