#!/bin/bash

export DISPLAY=':99'
export TZ='America/New_York'
sudo apt-get install openjdk-7-jre-headless
Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
sudo apt-get update
wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg --force-all -i puppetlabs-release-trusty.deb
sudo apt-get install xvfb
sudo apt-get -y install ntp 
sudo apt-get update
sudo apt-get install puppetmaster
sudo apt-get update
sudo apt-get install python-jenkinsapi
sudo apt-get update
sudo apt-get install puppet
sudo puppet resource package puppetmaster ensure=latest
sudo puppet resource service puppetmaster ensure=running enable=true
sudo puppet agent
