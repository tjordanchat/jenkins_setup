#!/bin/bash

# Run this script as root: 
# curl https://raw.githubusercontent.com/tjordanchat/jenkins_setup/master/install.sh | sh
# source /dev/stdin <<< "$( curl https://raw.githubusercontent.com/tjordanchat/jenkins_setup/master/install.sh )"
# Create seed job manually. Allow it to be executed remotely. Run the build with:
# curl -I -u <user>:<password> '<Jenkins URL>/job/<job name>/buildWothParameters?token=<token>&<PARAMETER>=<VALUE>'
# curl -I -u myuser:mypass 'http://localhost:8080/job/seed/buildWithParameters?token=phoenix&URL=myURL'

set -x
export PATH=$PATH:/snap/bin
export DISPLAY=':99'
export TZ='America/New_York'
git clone https://github.com/tjordanchat/jenkins_setup.git
chmod -R +rx . 
curl -sSL https://get.rvm.io | sudo bash -s stable
rvm list known
rvm install ruby-2.4.2
ruby -v
sudo apt install snapd
sudo apt-get update
sudo apt-get install firefox
sudo find / -name firefox -print
sudo snap install kubectl --classic
#sudo find / -name kubectl 2>/dev/null
kubectl version
kubectl cluster-info
sudo apt-get -y install openjdk-8-jre-headless
export PATH=$PATH:/usr/lib/jvm/java-8-openjdk-amd64/jre/bin
sudo apt-get update
sudo apt-get -y install xvfb
sudo apt-get update
sudo Xvfb $DISPLAY -screen 0 1024x768x24 > /dev/null 2>&1 &
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
export JENKINS_HOME=/var/lib/jenkins
#./jenkins_setup/bin/deploy_puppet
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get -y install jenkins
sudo touch /var/lib/jenkins/secrets/initialAdminPassword
sudo add-apt-repository ppa:rmescandon/yq
sudo apt update
sudo apt install yq -y
sudo apt-get install xorg openbox
sudo apt-get update
sleep 5
ps -ef | egrep jenkins
sudo netstat -tunpl
export PASS="$( sudo cat /var/lib/jenkins/secrets/initialAdminPassword )"
export CRUMB=$(curl -s 'http://127.0.0.1:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -u admin:$PASS)
curl -o jenkins-cli.jar http://127.0.0.1:8080/jnlpJars/jenkins-cli.jar
#java -jar ./jenkins-cli.jar -auth "admin:$PASS" -remoting -s http://127.0.0.1:8080 groovy ./jenkins_setup/groovy_dir/all_jobs.gsh
#curl --user admin:$PASS 
echo curl -H "$CRUMB" --data-urlencode -d script="$(<./jenkins_setup/groovy_dir/all_jobs.gsh)" http://127.0.0.1:8080/scriptText
curl -H "$CRUMB" --data-urlencode -d script="$(<./jenkins_setup/groovy_dir/all_jobs.gsh)" http://127.0.0.1:8080/scriptText
xargs java -jar ./jenkins-cli.jar -auth "admin:$PASS" -s http://127.0.0.1:8080 install-plugin < ./jenkins_setup/jenkins_dir/plugins.list
sudo mkdir -p /var/lib/jenkins/jobs/seed
sudo cp ./jenkins_setup/jenkins_dir/jobs/config.xml /var/lib/jenkins/jobs/seed
sudo chown jenkins /var/lib/jenkins/jobs/seed
sudo chown jenkins /var/lib/jenkins/jobs/seed/config.xml
sudo /etc/init.d/jenkins restart
sudo sed -i '' 's#<useSecurity>true</useSecurity>#<useSecurity>false</useSecurity>#' /var/lib/jenkins/config.xml
sudo /etc/init.d/jenkins restart
google-chrome-stable --no-first-run http://localhost:8080 &
#google-chrome-stable --headless --disable-gpu --remote-debugging-port=9222 http://localhost:8080 &
xterm -geometry 80x24+30+200 &
xclock -geometry 48x48-0+0 &
xload -geometry 48x48-96+0 &
xbiff -geometry 48x48-48+0 &
sleep 60
import -window root -crop 1264x948+0+0 -resize 1200x800 -quality 95 thumbnail.png
#ls -la
#od -c thumbnail.png
#ps -ef | egrep jenkins
#sudo netstat -tunpl
#cat /etc/passwd
#ifconfig eth0 | egrep inet
#curl -v -I -u admin:$PASS 'http://127.0.0.1:8080/job/seed/buildWithParameters?token=phoenix&URL=myURL'
#java -jar ./jenkins-cli.jar -auth "admin:$PASS" -s http://localhost:8080 build seed -p URL=myURL
