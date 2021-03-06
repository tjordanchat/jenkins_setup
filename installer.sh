#!/bin/bash

# Run this script as root: 
# curl https://raw.githubusercontent.com/tjordanchat/jenkins_setup/master/installer.sh | sh
# source /dev/stdin <<< "$( curl https://raw.githubusercontent.com/tjordanchat/jenkins_setup/master/installer.sh )"
# Create seed job manually. Allow it to be executed remotely. Run the build with:
# curl -I -u <user>:<password> '<Jenkins URL>/job/<job name>/buildWothParameters?token=<token>&<PARAMETER>=<VALUE>'
# curl -I -u myuser:mypass 'http://localhost:8080/job/seed/buildWithParameters?token=phoenix&URL=myURL'

checkcmd() {
  if [ $? != 0 ] 
  then
     toilet -f mono12 ERROR
     #printf '\e[0m'
  fi  
}

set -x
sudo apt-get update
sudo apt-get -y install toilet figlet
trap checkcmd DEBUG

export PATH=$PATH:/snap/bin
export DISPLAY=':99'
export TZ='America/New_York'
sudo chmod -R +rx . 
####################################
#   INSTALL RUBY
figlet  INSTALL RUBY
####################################
curl -sSL https://get.rvm.io | sudo bash -s stable
rvm install ruby-2.4.2
#ruby -v
####################################
#   INSTALL KUBERNETES
figlet   INSTALL KUBERNETES
####################################
#sudo apt install snapd
#sudo apt-get update
#sudo find / -name firefox -print
#sudo snap install kubectl --classic
#sudo find / -name kubectl 2>/dev/null
#kubectl version
#kubectl cluster-info
####################################
#   INSTALL JAVA
figlet   INSTALL JAVA
####################################
sudo apt-get -y install openjdk-8-jre-headless
export PATH=$PATH:/usr/lib/jvm/java-8-openjdk-amd64/jre/bin
####################################
#   INSTALL XVFB
figlet   INSTALL XVFB
####################################
sudo apt-get -y install xvfb
sudo Xvfb $DISPLAY -screen 0 1024x768x24 -extension RANDR  > /dev/null 2>&1 &
sudo apt-get update
####################################
#   INSTALL PUPPET
figlet   INSTALL PUPPET
####################################
sudo wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg --force-all -i puppetlabs-release-trusty.deb
sudo apt-get -y install puppetmaster
sudo apt-get -y install puppet
sudo apt-get update
#sudo puppet resource package puppetmaster ensure=latest
#sudo puppet resource service puppetmaster ensure=running enable=true
#sudo puppet agent
####################################
#   INSTALL DOCKER
figlet   INSTALL DOCKER
####################################
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl status docker | cat
sudo docker run hello-world
####################################
#   INSTALL JENKINS
figlet   INSTALL JENKINS
####################################
export JENKINS_HOME=/var/lib/jenkins
#./jenkins_setup/bin/deploy_puppet
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get -y install jenkins
#sudo sed -i \'\' \'s#<useSecurity>true</useSecurity>#<useSecurity>false</useSecurity>#\' /var/lib/jenkins/config.xml
sudo -H -u jenkins bash -c 'cp '$HOME'/jenkins_setup/jenkins_dir/config.xml /var/lib/jenkins/config.xml'
sudo /etc/init.d/jenkins start
sleep 60
export PASS="$( sudo cat /var/lib/jenkins/secrets/initialAdminPassword )"
export CRUMB=$(curl -s 'http://127.0.0.1:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -u admin:$PASS)
sudo touch /var/lib/jenkins/secrets/initialAdminPassword
#ps -ef | egrep jenkins
#sudo netstat -tunpl
####################################
#   INSTALL JENKINS PLUGINS
figlet   INSTALL JENKINS PLUGINS
####################################
xargs java -jar ./jenkins-cli.jar -auth "admin:$PASS" -s http://127.0.0.1:8080 install-plugin < ./jenkins_dir/plugins.list
####################################
#   INSTALL JENKINS JOB
figlet   INSTALL JENKINS JOB
####################################
sudo mkdir -p /var/lib/jenkins/jobs/seed
sudo cp $HOME/jenkins_setup/jenkins_dir/jobs/config.xml /var/lib/jenkins/jobs/seed
sudo chown jenkins:jenkins /var/lib/jenkins/jobs
sudo chown jenkins:jenkins /var/lib/jenkins/jobs/seed
sudo chown jenkins:jenkins /var/lib/jenkins/jobs/seed/config.xml
sudo find /var/lib/jenkins/jobs -ls
sudo /etc/init.d/jenkins restart
sleep 60
####################################
#   CHANGE JENKINS SECURITY
figlet   CHANGE JENKINS SECURITY
####################################
ls -l /var/lib/jenkins/config.xml
#sudo find / -name jenkins.war 2>/dev/null
#sudo java -Djenkins.install.runSetupWizard=false -jar /usr/share/jenkins/jenkins.war
echo "CRUMB: $CRUMB PASSWORD: $PASS"
curl "admin:$PASS@127.0.0.1:8080/j_acegi_security_check" -X POST -d '{"from":"","j_username":"admin","j_password":'$PASS',"Jenkins-Crumb":'$CRUMB'}'
#####################################
#   INSTALL MISC
figlet   INSTALL MISC
#####################################
sudo add-apt-repository ppa:rmescandon/yq
sudo apt update
sudo apt install yq -y
sudo apt-get -y install xorg openbox
sudo apt-get -y install ntp 
sudo apt-get -y install inotify-tools
sudo apt-get -y install imagemagick
sudo apt-get update
#####################################
#   RUN APPLICATIONS
figlet   RUN APPLICATIONS
#####################################
#xterm -geometry 80x24+30+200 &
#xload -geometry 48x48-96+0 &
xclock -geometry 48x48-0+0 &
xbiff -geometry 48x48-48+0 &
sleep 60
sudo ln -s /var/lib/dbus/machine-id /etc/machine-id
google-chrome-stable --no-first-run http://127.0.0.1:8080/me/my-views/view/all/ &
sleep 2
curl -o jenkins-cli.jar http://127.0.0.1:8080/jnlpJars/jenkins-cli.jar
curl -H "$CRUMB" --data-urlencode -d script="$(<$HOME/jenkins_setup/groovy_dir/all_jobs.gsh)" http://127.0.0.1:8080/scriptText
#####################################
#   RUN SEED JOB
figlet   RUN SEED JOB
#####################################
curl -s 'http://127.0.0.1:8080/job/seed/buildWithParameters%3Ftoken=phoenix%26URL=myURL' -u admin:$PASS
#####################################
#   TAKE SCREENSHOT
figlet   TAKE SCREENSHOT
#####################################
import -window root -crop 1264x948+0+0 -resize 1200x800 -quality 95 thumbnail.png
#ls -la
#od -c thumbnail.png
#ps -ef | egrep jenkins
#sudo netstat -tunpl
#cat /etc/passwd
#ifconfig eth0 | egrep inet
#java -jar ./jenkins-cli.jar -auth "admin:$PASS" -s http://localhost:8080 build seed -p URL=myURL
set +x
