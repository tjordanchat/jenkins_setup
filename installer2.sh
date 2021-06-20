#!/bin/bash
set -v -x -e

# Run this script as root: 
# curl https://raw.githubusercontent.com/tjordanchat/jenkins_setup/master/installer.sh | sh
# source /dev/stdin <<< "$( curl https://raw.githubusercontent.com/tjordanchat/jenkins_setup/master/installer.sh )"
# Create seed job manually. Allow it to be executed remotely. Run the build with:
# curl -I -u <user>:<password> '<Jenkins URL>/job/<job name>/buildWothParameters?token=<token>&<PARAMETER>=<VALUE>'
# curl -I -u myuser:mypass 'http://localhost:8080/job/seed/buildWithParameters?token=phoenix&URL=myURL'

#env

----- () {
    printf "\e[32m"
    toilet -f term -F border  $@ 
    printf "\e[0m"
}

sudo apt-get -f install
sudo apt-get update -y 2>/dev/null
sudo apt-get install -y toilet toilet-fonts
sudo apt-get -f install figlet -y
ls -la /usr/share/figlet

----- `pwd`
pwd
ls -la
----- $TRAVIS_COMMIT

###################################
----- DEFINE VARIABLES
###################################

export CRUMB=''
export MYHOME="$(pwd)"
export DISPLAY=':99'
export TZ='America/New_York'
export JENKINS_HOME=/var/lib/jenkins
export PATH=$PATH:/usr/lib/jvm/java-8-openjdk-amd64/jre/bin
export PATH=$PATH:/snap/bin
export TRAVIS_BUILD_DIR=${TRAVIS_BUILD_DIR:-`pwd`}

###################################
----- DEFINE FUNCTIONS
###################################

Update_Package_Manager () {
   ----- UPDATE PACKAGE MANAGER
   sudo apt-get update
}

Install_Ruby () {
   ----- INSTALL RUBY
   sudo apt-get -f install ruby-full

}

Install_Java () {
   ----- INSTALL JAVA
   sudo apt-get -f -y install  openjdk-8-jre-headless
}

Install_Virtual_Frame_Buffer () {
   ----- INSTALL VIRTUAL FRAME BUFFER
   sudo apt-get -f -y install xvfb
}

Run_Virtual_Frame_Buffer () {
   ----- RUN VIRTUAL FRAME BUFFER
   sudo Xvfb $DISPLAY -screen 0 1024x768x24 -extension RANDR  > /dev/null 2>&1 &
}

Install_Puppet () {
   ----- INSTALL PUPPET
   sudo wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
   sudo dpkg --force-all -i puppetlabs-release-trusty.deb
   sudo apt-get -f -y install  puppetmaster
   sudo apt-get -f -y install  puppet
}

Install_Docker () {
   ----- INSTALL DOCKER
   sudo apt install apt-transport-https ca-certificates curl software-properties-common
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
   apt-cache policy docker-ce
   sudo apt install docker-ce -y
   sudo systemctl status docker | cat
   sudo docker run hello-world
}

Install_Jenkins () {
   ----- INSTALL JENKINS
   cd $MYHOME
   wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war 2> /dev/null > /dev/null
   #sudo bash -c 'cp '$TRAVIS_BUILD_DIR'/jenkins_dir/config.xml /var/lib/jenkins/config.xml'   
}

Run_Jenkins () {
   ----- RUN JENKINS
   cd $MYHOME
   sudo java -Djenkins.install.runSetupWizard=false -jar jenkins.war &
   #sudo /etc/init.d/jenkins start
   sleep 60
}

Install_Jenkins_Plugins () {
   ----- INSTALL JENKINS PLUGINS
   #python $MYHOME/python_dir/version.py "$PASS"
   curl -o jenkins-cli.jar http://127.0.0.1:8080/jnlpJars/jenkins-cli.jar
   #curl -H "$CRUMB" --data-urlencode -d script="$(<$MYHOME/groovy_dir/all_jobs.gsh)" http://127.0.0.1:8080/scriptText
   sudo xargs java -jar ./jenkins-cli.jar -auth "admin:$PASS" -s http://127.0.0.1:8080 install-plugin < $MYHOME/jenkins_dir/plugins.list
}

Run_Build () {
   sudo java -jar ./jenkins-cli.jar -auth "admin:$PASS" -s http://127.0.0.1:8080  build seed -p URL="$1" -s -v
}

Install_Initial_Jenkins_Jobs () {
   ----- INSTALL INITIAL JENKINS JOBS
   curl -o jenkins-cli.jar http://127.0.0.1:8080/jnlpJars/jenkins-cli.jar
   sudo mkdir -p /var/lib/jenkins/jobs/seed
   sudo cp $MYHOME/jenkins_dir/jobs/config.xml /var/lib/jenkins/jobs/seed
   #sudo java -Dorg.xml.sax.driver=com.sun.org.apache.xerces.internal.parsers.SAXParser -jar ./jenkins-cli.jar -auth "admin:$PASS" -s http://127.0.0.1:8080  create-job seed  < $MYHOME/jenkins_dir/jobs/config.xml
}

Install_Misc_Tools () {
   ----- INSTALL MISC TOOLS
   sudo add-apt-repository ppa:rmescandon/yq
   sudo apt install yq -y || sudo pip install yq
   sudo apt-get -f -y install xorg openbox 2>/dev/null
   sudo apt-get install -y x11-apps
   sudo apt-get -f -y install ntp 
   sudo apt-get -f -y install inotify-tools
   sudo apt-get -f -y install imagemagick 2>/dev/null
   sudo pip install python-jenkins
}

Run_Applications () {
   xclock -geometry 48x48-0+0 &
   xbiff -geometry 48x48-48+0 &
   wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb 2>/dev/null
   sudo apt-get install ./google-chrome-stable_current_amd64.deb
   google-chrome-stable --no-first-run http://127.0.0.1:8080 &
   #google-chrome-stable --no-first-run http://127.0.0.1:8080/me/my-views/view/all/ &
   sleep 10
}

Take_Screenshot () {
   import -window root -crop 1264x948+0+0 -resize 1200x800 -quality 95 thumbnail.png
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

trap Trap_Errors DEBUG

Update_Package_Manager
Install_Ruby
Install_Java
Install_Jenkins

####################################
----- FETCH JENKINS PASSWD and CRUMB
####################################

export PASS=""

Install_Misc_Tools
Install_Virtual_Frame_Buffer
Run_Virtual_Frame_Buffer

####################################
----- RUN JENKINS - TAKE SCREENSHOT
####################################

Run_Jenkins
Run_Applications
Take_Screenshot

export CRUMB=$(curl -s 'http://127.0.0.1:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')
CRUMB=$( echo $CRUMB | sed 's/Jenkins-Crumb://')
#export CRUMB=$(curl -s 'http://127.0.0.1:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -u admin:$PASS)

Install_Jenkins_Plugins
Install_Initial_Jenkins_Jobs

####################################
----- RUN THE BUILD
####################################

Run_Build https://github.com/tjordanchat/eag.git


