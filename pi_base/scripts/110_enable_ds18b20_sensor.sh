#!/bin/bash
#  Expects ds18b20_gpio_pin to be set 
#    Required environment variables:
#      ds18b20_gpio_pin
#
#  If this variable is set, this script should be generic enough to run on any pi

function banner(){ time=`date +"%Y-%m-%d %H:%M:%S"`; printf "$time | "; printf '=%.0s' {1..40}; printf "[ ${1} ]"; printf '=%.0s' {1..40}; echo; }

if [[ "${ds18b20_gpio_pin}" == "" ]]; then
    export ds18b20_gpio_pin=4
    echo "ds18b20_gpio_pin variable not set - defaulting to ${ds18b20_gpio_pin}"
fi

banner "Configuring DS18B20 W1 Driver on GPIO Pin ${ds18b20_gpio_pin}"


################################################################################
#  Configure the temperature sensor
################################################################################

BOOT=/boot/config.txt
# Only run this if the ds18b20 hasn't already been added to the boot file
if [[ $( grep -c w1-gpio $BOOT ) == 0 ]]; then
   cat >> $BOOT << DTO 
# Enable the DS18B20 sensor on GPIO pin ${ds18b20_gpio_pin} 
dtoverlay=w1-gpio, gpiopin=${ds18b20_gpio_pin}
DTO
else 
    echo "${BOOT} file already contained w1-gpio driver"
fi

# Modprobe won't work when running in docker/qemu for ARM since the kernel
# is really the x86 Linux kernel; so try using this technique instead
# modprobe w1-gpio
# modprobe w1-therm
cat > /etc/modules-load.d/w1-driver << EOF
w1-gpio
w1-therm
EOF

##  cd /sys/bus/w1/devices/
##  ls 
##  
##  # Make note of the serial number attached
##  # 28-011601192dee 
##  cd 28-011601192dee
##  cat w1_slave 
##  
##  #the t= is the temperature in celsius
##  #pi@pitres /sys/bus/w1/devices $ cd 28-011601192dee
##  #pi@pitres /sys/bus/w1/devices/28-011601192dee $ cat w1_slave 
##  #64 01 4b 46 7f ff 0c 10 01 : crc=01 YES
##  #64 01 4b 46 7f ff 0c 10 01 t=22250
##  #pi@pitres /sys/bus/w1/devices/28-011601192dee $ 
