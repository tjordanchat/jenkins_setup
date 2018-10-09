#!/bin/bash

# Run this script as root: 
# curl https://raw.githubusercontent.com/tjordanchat/jenkins_setup/master/install.sh | sh

set -x
export DISPLAY=':99'
export TZ='America/New_York'
git clone https://github.com/tjordanchat/jenkins_setup.git
apt-get update
apt-get -y install openjdk-8-jre-headless
export PATH=$PATH:/usr/lib/jvm/java-8-openjdk-amd64/jre/bin
apt-get update
apt-get -y install xvfb
apt-get update
Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
dpkg --force-all -i puppetlabs-release-trusty.deb
apt-get -y install ntp 
apt-get update
apt-get -y install puppetmaster
apt-get update
apt-get -y install puppet
apt-get update
puppet resource package puppetmaster ensure=latest
puppet resource service puppetmaster ensure=running enable=true
puppet agent
adduser --disabled-password myuser
usermod -aG sudo myuser
mkdir -p ~myuser/.ssh
chown myuser ~myuser/.ssh
chmod 700 ~myuser/.ssh
cp ~/.ssh/authorized_keys ~myuser/.ssh
chown myuser ~myuser/.ssh/authorized_keys
chmod 600 ~myuser/.ssh/authorized_keys
cp -f ./jenkins_setup/.bashrc ./jenkins_setup/.vimrc .
export JENKINS_HOME=/var/lib/jenkins
#./jenkins_setup/bin/deploy_puppet
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get -y install jenkins
sleep 5
export PASS="$( sudo cat /var/lib/jenkins/secrets/initialAdminPassword )"
export CRUMB=$(curl -s 'http://127.0.0.1:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -u admin:$PASS | sed 's/Jenkins-Crumb/.crumb/')
curl -o jenkins-cli.jar http://127.0.0.1:8080/jnlpJars/jenkins-cli.jar
xargs java -jar ~/jenkins-cli.jar -auth "admin:$PASS" -s http://127.0.0.1:8080 install-plugin < ./jenkins_setup/jenkins_dir/plugins.list
#curl --user admin:$PASS -d "$CRUMB" --data-urlencode "script=$(<./jenkins_setup/jenkins_dir/dsl/pipeline.groovy)" http://127.0.0.1:8080/scriptText
curl -s -XPOST 'http://127.0.0.1:8080/createItem?name=Pipeline' -u admin:$PASS --data-binary @./jenkins_setup/jenkins_dir/jobs/config.xml -H "$CRUMB" -H "Content-Type:application/xml"
#rm -rf jenkins_setup

ps -ef | egrep jenkins
netstat -tunpl
cat /etc/passwd
