#!/bin/bash

# Run this script as root: 
# curl https://raw.githubusercontent.com/tjordanchat/jenkins_setup/master/install.sh | sh
# source /dev/stdin <<< "$( curl https://raw.githubusercontent.com/tjordanchat/jenkins_setup/master/install.sh )"
# Create seed job manually. Allow it to be executed remotely. Run the build with:
# curl -I -u <user>:<password> '<Jenkins URL>/job/<job name>/buildWothParameters?token=<token>&<PARAMETER>=<VALUE>'
# curl -I -u tjordan:1234567 'http://localhost:8080/job/seed/buildWithParameters?token=phoenix&URL=myURL'

set -x
export DISPLAY=':99'
export TZ='America/New_York'
git clone https://github.com/tjordanchat/jenkins_setup.git
chmod -R +rx . 
sudo apt-get update
sudo apt-get -y install openjdk-8-jre-headless
export PATH=$PATH:/usr/lib/jvm/java-8-openjdk-amd64/jre/bin
sudo apt-get update
sudo apt-get -y install xvfb
sudo apt-get update
sudo Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
sudo wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg --force-all -i puppetlabs-release-trusty.deb
sudo apt-get -y install ntp 
sudo apt-get update
sudo apt-get -y install puppetmaster
sudo apt-get update
sudo apt-get -y install puppet
sudo apt-get update
sudo apt-get -y install inotify-tools
sudo apt-get update
puppet resource package puppetmaster ensure=latest
puppet resource service puppetmaster ensure=running enable=true
puppet agent
sudo adduser --disabled-password myuser
sudo usermod -aG sudo myuser
sudo mkdir -p ~myuser/.ssh
sudo chown myuser ~myuser/.ssh
sudo chmod 700 ~myuser/.ssh
sudo cp ~/.ssh/authorized_keys ~myuser/.ssh
sudo chown myuser ~myuser/.ssh/authorized_keys
sudo chmod 600 ~myuser/.ssh/authorized_keys
sudo cp -f ./jenkins_setup/.bashrc ./jenkins_setup/.vimrc .
export JENKINS_HOME=/var/lib/jenkins
#./jenkins_setup/bin/deploy_puppet
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get -y install jenkins
sudo touch /var/lib/jenkins/secrets/initialAdminPassword
sudo inotifywait -e close_write /var/lib/jenkins/secrets
sudo add-apt-repository ppa:rmescandon/yq
sudo apt update
sudo apt install yq -y
sleep 8
export PASS="$( sudo cat /var/lib/jenkins/secrets/initialAdminPassword )"
export CRUMB=$(curl -s 'http://127.0.0.1:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -u admin:$PASS)
curl -o jenkins-cli.jar http://127.0.0.1:8080/jnlpJars/jenkins-cli.jar
xargs java -jar ~/jenkins-cli.jar -auth "admin:$PASS" -s http://127.0.0.1:8080 install-plugin < ./jenkins_setup/jenkins_dir/plugins.list
su -c "mkdir -p /var/lib/jenkins/jobs/seed" jenkins
su -c "cp /root/jenkins_setup/jenkins_dir/jobs/config.xml /var/lib/jenkins/jobs/seed" jenkins
/etc/init.d/jenkins restart
#java -jar jenkins-cli.jar -auth "admin:$PASS" -s http://localhost:8080/ create-job seed < ./jenkins_setup/jenkins_dir/jobs/config.xml
#curl --user admin:$PASS -d "$CRUMB" --data-urlencode "script=$(<./jenkins_setup/jenkins_dir/dsl/pipeline.groovy)" http://127.0.0.1:8080/scriptText
#curl -s -XPOST 'http://127.0.0.1:8080/createItem?name=Pipeline' -u admin:$PASS --data-binary @./jenkins_setup/jenkins_dir/jobs/config.xml -H "$CRUMB" -H "Content-Type:application/xml"
#rm -rf jenkins_setup

ps -ef | egrep jenkins
sudo netstat -tunpl
cat /etc/passwd
echo $PASS
ifconfig eth0 | egrep inet 
