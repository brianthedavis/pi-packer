#!/bin/bash
#  Initial image setup 
#    Required environment variables:
#      os_user
#      newhost
#      homedir

set -x

function banner(){ time=`date +"%Y-%m-%d %H:%M:%S"`; printf "$time | "; printf '=%.0s' {1..40}; printf "[ ${1} ]"; printf '=%.0s' {1..40}; echo; }

banner "Runtime Environment" ########################################################
env



# Set the default password of the pi user
#  Encrypt the password using this command:
#     > openssl passwd -6 -salt xyz PASSWORD
printf "${os_user}:%s" '$6$xyz$qg/0jfcKxkQMt.3Cn7/.uym/Te1' | chpasswd --encrypted

################################################################################
#  Link in configuration files
################################################################################
LINK_LIST=( .bashrc .bash_aliases .vim )
for LINK in ${LINK_LIST[@]}; do
	echo "Linking ${homedir}/${LINK}"
	mv ${homedir}/${LINK}    ${homedir}/${LINK}.orig
	ln -s ${homedir}/scripts/${LINK} ${homedir}/${LINK} 
done
ln -s ${homedir}/scripts/brian_pivimrc.vim ${homedir}/.vimrc



################################################################################
#  Configure SSH
################################################################################
# Enable ssh by placing a ssh file in /boot
# https://www.raspberrypi.org/documentation/remote-access/ssh/README.md
touch /boot/ssh

# Generate an SSH Key for this host and attach it to the pi's authorized keys
mkdir ${homedir}/.ssh
cat << SSH_CONFIG > ${homedir}/.ssh/config
LogLevel=quiet 
Host *
	StrictHostKeyChecking no
	#UserKnownHostsFile=/dev/null
SSH_CONFIG

ssh-keygen -f ${homedir}/.ssh/id_rsa -t rsa -N '' -C "${os_user}@$newhost"

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
cat << SSHD_CONFIG >> /etc/ssh/sshd_config
# Allow password logins internally, but not externally
	ChallengeResponseAuthentication no
	PasswordAuthentication no

# Allow internal addresses to use a password, all external must use keys
# this block must be at the end of the file
Match Address 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
PasswordAuthentication yes
SSHD_CONFIG

# Disable root login in /etc/sshd/sshd_config
# PermitRootLogin no
# LoginGraceTime 30

### Renew the SSH server keys
# Delete the server key
shred -u /etc/ssh/ssh_host_*

# Now regenerate the keys
dpkg-reconfigure openssh-server

################################################################################
#  Basic parameter configs
################################################################################

# Configure the gpu_mem to the lowest value: 16
cp /boot/config.txt /boot/config.txt.orig
echo -e "\n# Minimal GPU Memory\ngpu_mem=16\n" >> /boot/config.txt

cp /etc/default/keyboard /etc/default/keyboard.orig
cat << KEYBD > /etc/default/keyboard
XKBLAYOUT=us
XKBVARIANT= 
XKBOPTIONS=compose:menu,ctrl:nocaps
KEYBD

# Force the pi to reboot automatically after 20 seconds if there is a kernel panic
cp /etc/sysctl.conf /etc/sysctl.conf.orig
echo "kernel.panic = 20" >> /etc/sysctl.conf

# Disable apt-get from trying to use ipv6 which currently doesn't work on my network
echo 'Acquire::ForceIPv4 "true";' >  /etc/apt/apt.conf.d/99force-ipv4

#  Set the timezone
ln -sf /usr/share/zoneinfo/US/Mountain /etc/localtime
#timedatectl

# Prevent rsyslog from filling up
sed -i '/# The named pipe \/dev\/xconsole/,$d' /etc/rsyslog.conf

# Install the correct locale
echo -e 'LANG=en_US.UTF-8\nLC_ALL=en_US.UTF-8' > /etc/default/locale
echo -e "en_US.UTF-8 UTF-8\n" > /etc/locale.gen
apt-get install --yes debconf locales
/usr/sbin/locale-gen

#### Configure the root .bashrc to enable color coding and aliases
cat >> /root/.bashrc <<EOF
# If not running interactively, don't do anything
[ -z "\$PS1" ] && return

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set a fancy prompt (non-color, unless we know we "want" color)
case "\$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "\$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  # We have color support; assume it's compliant with Ecma-48
  # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
  # a case would tend to support setf rather than setaf.)
  color_prompt=yes
    else
  color_prompt=
    fi
fi

if [ "\$color_prompt" = yes ]; then
    PS1='\${debian_chroot:+(\$debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]\w #\[\033[00m\] '
else
    PS1='\${debian_chroot:+(\$debian_chroot)}\u@\h:\w\# '
fi
unset color_prompt force_color_prompt


# If this is an xterm set the title to user@host:dir
case "\$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;\${debian_chroot:+(\$debian_chroot)}\u@\h: \w\a\]\$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "\$(dircolors -b ~/.dircolors)" || eval "\$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -lh'

EOF

