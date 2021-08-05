# Raspberry Pi Packer Image Builds
This directory contains a set of packer images to build for Raspberry Pi using the 
`docker.pkg.github.com/solo-io/packer-builder-arm-image/packer-builder-arm` container. 
Alternatively, this image can be built on a Linux machine using `../docker/build_packer-builder-arm_container.sh`.

Packer/packer-builder-arm seems to have a few bugs where I run into:
* Image doesn't get resized properly (causing an out of space error)
* Loopback device not available
* apt-get cannot find repo
All of these require a rebuild and/or restarting the Docker daemon.  
Typically the missing /dev/loop device requires the Docker daemon (i.e. underlying Docker VM on MacOS) to be restarted.  
Many of the underlying scripts perform checks to attempt to mitigate these errors (instead of wasting time on the image build).

## Establish the base image
You can pick a Raspbian image straight from the website or download it first and create your own checksum. 
On the mac, run the following command to generate a SHA256 checksum of the base image:
`shasum -a 256 /Volumes/D/Install\ SW/Raspberry\ Pi/2020-02-13-raspbian-buster-lite.zip`


## Build the base image
* First, log in to GitHub
  * `docker login -u brianthedavis -p TOKEN docker.pkg.github.com`
  * You may need to create a token at (https://github.com/settings/tokens)
  * `docker pull docker.pkg.github.com/solo-io/packer-builder-arm-image/packer-builder-arm:latest`

* Now build: run `build` inside the `pi_base` path
`./build`

## Establish a new specific image
Run `create_new_image_dir.sh <imagename>` to create a new template directory based on the base image.  
New images are not built off the pi_base image itself, instead it constructs a new image based on the pi_base scripts.  `create_new_image_dir.sh` creates a new
blank directory that can be modified as needed pointing to `pi_base` and `setup/<imagename>`

