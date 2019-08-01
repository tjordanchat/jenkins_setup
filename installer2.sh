#!/bin/bash

# Run this script as root: 
# curl https://raw.githubusercontent.com/tjordanchat/jenkins_setup/master/installer.sh | sh
# source /dev/stdin <<< "$( curl https://raw.githubusercontent.com/tjordanchat/jenkins_setup/master/installer.sh )"
# Create seed job manually. Allow it to be executed remotely. Run the build with:
# curl -I -u <user>:<password> '<Jenkins URL>/job/<job name>/buildWothParameters?token=<token>&<PARAMETER>=<VALUE>'
# curl -I -u myuser:mypass 'http://localhost:8080/job/seed/buildWithParameters?token=phoenix&URL=myURL'

----- () {
   figlet $@
}

sudo apt-get update
sudo apt-get -y install toilet figlet

###################################
----- DEFINE VARIABLES
###################################

export DISPLAY=':99'
export TZ='America/New_York'
export JENKINS_HOME=/var/lib/jenkins
export PATH=$PATH:/usr/lib/jvm/java-8-openjdk-amd64/jre/bin
export PATH=$PATH:/snap/bin

###################################
----- DEFINE FUNCTIONS
###################################

Update_Package_Manager () {
   ----- UPDATE PACKAGE MANAGER
   sudo apt-get update
}

Install () {
   ----- INSTALL $@
   sudo apt-get -y install $@
}

Install_Ruby () {
   ----- INSTALL RUBY
   curl -sSL https://get.rvm.io | sudo bash -s stable
   rvm install ruby-2.4.2
}

Install_Java () {
   ----- INSTALL JAVA
   Install openjdk-8-jre-headless
}

Install_Virtual_Frame_Buffer () {
   ----- INSTALL VIRTUAL FRAME BUFFER
   sudo apt-get -y install xvfb
}

Run_Virtual_Frame_Buffer () {
   ----- RUN VIRTUAL FRAME BUFFER
   sudo Xvfb $DISPLAY -screen 0 1024x768x24 -extension RANDR  > /dev/null 2>&1 &
}

Install_Puppet () {
   ----- INSTALL PUPPET
   sudo wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
   sudo dpkg --force-all -i puppetlabs-release-trusty.deb
   Install puppetmaster
   Install puppet
}

Install_Docker () {
   ----- INSTALL DOCKER
   sudo apt install apt-transport-https ca-certificates curl software-properties-common
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
   apt-cache policy docker-ce
   sudo apt install docker-ce
   sudo systemctl status docker | cat
   sudo docker run hello-world
}

Install_Jenkins () {
   ----- INSTALL JENKINS
   wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
   sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
   sudo apt update
   sudo apt install jenkins
   sudo ls -l /home/travis/jenkins_setup/jenkins_dir/config.xml /var/lib/jenkins/config.xml
   sudo -H -u jenkins bash -c 'cp '$HOME'/jenkins_setup/jenkins_dir/config.xml /var/lib/jenkins/config.xml'   
}

Run_Jenkins () {
   ----- RUN JENKINS
   sudo /etc/init.d/jenkins start
   sleep 60
}

Install_Jenkins_Plugins () {
   ----- INSTALL JENKINS PLUGINS
   xargs java -jar ./jenkins-cli.jar -auth "admin:$PASS" -s http://127.0.0.1:8080 install-plugin < ./jenkins_dir/plugins.list
}

Install_Initial_Jenkins_Jobs () {
   ----- INSTALL INITIAL JENKINS JOBS
   sudo mkdir -p /var/lib/jenkins/jobs/seed
   sudo cp $HOME/jenkins_setup/jenkins_dir/jobs/config.xml /var/lib/jenkins/jobs/seed
   sudo chown jenkins:jenkins /var/lib/jenkins/jobs
   sudo chown jenkins:jenkins /var/lib/jenkins/jobs/seed
   sudo chown jenkins:jenkins /var/lib/jenkins/jobs/seed/config.xml
   sudo find /var/lib/jenkins/jobs -ls
   sudo /etc/init.d/jenkins restart
   sleep 60
}

Install_Misc_Tools () {
   ----- INSTALL MISC TOOLS
   sudo add-apt-repository ppa:rmescandon/yq
   sudo apt install yq -y
   sudo apt-get -y install xorg openbox
   sudo apt-get -y install ntp 
   sudo apt-get -y install inotify-tools
   sudo apt-get -y install imagemagick
}

Run_Build () {
   ----- RUN BUILD
   xclock -geometry 48x48-0+0 &
   xbiff -geometry 48x48-48+0 &
   sudo ln -s /var/lib/dbus/machine-id /etc/machine-id
   google-chrome-stable --no-first-run http://127.0.0.1:8080/me/my-views/view/all/ &
   curl -o jenkins-cli.jar http://127.0.0.1:8080/jnlpJars/jenkins-cli.jar
}

Trap_Errors () {
  if [ $? != 0 ] 
  then
     toilet -f mono12 ERROR
  fi  
}

####################################
----- RUN BUILD ENVIRONMENT
####################################

set -v -x -e
trap Trap_Errors DEBUG

Update_Package_Manager
#Install_Ruby
Install_Java
Install_Jenkins
Install_Misc_Tools
Install_Virtual_Frame_Buffer
Run_Virtual_Frame_Buffer
Run_Jenkins

####################################
----- FETCH JENKINS PASSWD & CRUMP
####################################

export PASS="$( sudo cat /var/lib/jenkins/secrets/initialAdminPassword )"
export CRUMB=$(curl -s 'http://127.0.0.1:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -u admin:$PASS)

####################################
----- RUN THE BUILD
####################################

Run_Build


