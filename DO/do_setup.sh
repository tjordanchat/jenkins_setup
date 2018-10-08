#!/bin/bash

# Run this script as root: 
# curl https://raw.githubusercontent.com/tjordanchat/jenkins_setup/master/DO/do_setup.sh | sh

export DISPLAY=':99'
export TZ='America/New_York'
apt-get install openjdk-7-jre-headless
apt-get install xvfb
Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
sudo apt-get update
wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
dpkg --force-all -i puppetlabs-release-trusty.deb
apt-get -y install ntp 
apt-get update
apt-get install puppetmaster
apt-get update
apt-get install python-jenkinsapi
apt-get update
apt-get install puppet
puppet resource package puppetmaster ensure=latest
puppet resource service puppetmaster ensure=running enable=true
puppet agent
useradd -m myuser
usermod -aG sudo myuser
mkdir -p ~myuser/.ssh
chown myuser ~myuser/.ssh
chmod 700 ~myuser/.ssh
cp ~/.ssh/authorized_keys ~myuser/.ssh
chown ~myuser/.ssh/authorized_keys
chmod 600 ~myuser/.ssh/authorized_keys
sleep 5
ps -ef | egrep jenkins
netstat -tunpl
