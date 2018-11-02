#!/bin/bash

sudo apt-get update
sudo rm /boot/grub/menu.lst

sudo apt-get upgrade -y
sudo apt-get install -y --no-install-recommends apt-transport-https apt-show-versions bash-completion logrotate ntp ntpdate htop vim curl dbus bmon nmon parted wget rsyslog ethtool unzip zip tcpdump strace tar libyaml-0-2 lsb-base lsb-release xfsprogs sysfsutils software-properties-common

# Disable daily apt unattended updates.
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic
