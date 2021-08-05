#!/bin/bash
# Fire up a docker container to poke around the most recently
# built raspbian image
# Note: this just mounts the filesystem - the QEMU emulation won't work
# so nothing will properly fire up -- you can just poke around the container
#
# docker run -it --rm --privileged -v /images:/images ubuntu bash
# Note: this will occasionally fail due to the loopback device; just run it again (not sure why...)

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Packer image output
IMAGE_PATH=${DIR}/output-arm-image
IMAGE_NAME=image

# Base Image
# IMAGE_PATH="/Volumes/D/Install SW/Raspberry Pi"
# IMAGE_NAME=2020-02-13-raspbian-buster-lite.img

docker run -it --rm --privileged=true \
    -v "${IMAGE_PATH}":/usr/rpi/images \
    -w /usr/rpi \
    ryankurte/docker-rpi-emu \
    /bin/bash -c "./run.sh /usr/rpi/images/${IMAGE_NAME} /bin/bash"


# THIS WORKS!!!!!
docker run --rm -it --privileged -v "$(pwd)/output-arm-image":/images debian /bin/bash
LOOP=$( losetup -f )
losetup --offset $((532480*512)) ${LOOP} /images/image
mount -t ext4 ${LOOP} /mnt


# docker run --rm -it --privileged  \
#     -v "${DIR}/output-arm-image":/images \
#     debian \
#     /bin/bash
# sudo fdisk -d output-arm-image/image 
# sudo fdisk -d "/Volumes/D/Install SW/Raspberry Pi/2020-02-13-raspbian-buster-lite.img" 


# mkdir /mnt/boot
# mkdir /mnt/root
# mount -o loop,offset=$((8192*512))    /images/image /mnt/boot
# mount -t ext4 "/images/image" -o loop,offset=$((532480*512)),sizelimit=$((8388607*512))  /mnt/root
# root@30f80d4598dc:/# fdisk -l /images/2016-09-23-raspbian-jessie-lite.img 
# Disk /images/2016-09-23-raspbian-jessie-lite.img: 1.3 GiB, 1389363200 bytes, 2713600 sectors
# Units: sectors of 1 * 512 = 512 bytes
# Sector size (logical/physical): 512 bytes / 512 bytes
# I/O size (minimum/optimal): 512 bytes / 512 bytes
# Disklabel type: dos
# Disk identifier: 0x5a7089a1

# Device                                       Boot  Start     End Sectors  Size Id Type
# /images/2016-09-23-raspbian-jessie-lite.img1        8192  137215  129024   63M  c W95 FAT
# /images/2016-09-23-raspbian-jessie-lite.img2      137216 2713599 2576384  1.2G 83 Linux
# And mount it:

# root@952a75f105ee:/# mount -o loop,offset=$((137216*512))  /images/2016-09-23-raspbian-jessie-lite.img /mnt
# root@952a75f105ee:/# ls /mnt
# bin   dev  home  lib64       media  opt   root  sbin  sys  usr
# boot  etc  lib   lost+found  mnt    proc  run   srv   tmp  var
# root@952a75f105ee:/# 