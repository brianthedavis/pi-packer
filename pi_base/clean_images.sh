#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IMGPATH="${DIR}/output-arm-image"

rm -rf "${IMGPATH}"