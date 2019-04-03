#!/usr/bin/env bash

packages=(
    tree
    mc
    git
    curl
    wget
    unzip
    java-1.8.0-openjdk-devel.x86_64
    vim
    sshpass.x86_64
)
yum install -y "${packages[@]}"

# Add java varibles to environment
cat << EOF > /etc/environment
export JAVA_HOME='/usr/lib/jvm/jre-1.8.0-openjdk'
export JRE_HOME='/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.191.b12-1.el7_6.x86_64/jre'
EOF
source /etc/environment

# Jenkins install
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum install jenkins -y
systemctl start jenkins

echo "Waiting 1 minutes before Jenkins up and running"
sleep 1m

# Download Jenkins CLI
if [ ! -f "/home/vagrant/jenkins-cli.jar" ]
then
wget http://epm-jmaster1:8080/jnlpJars/jenkins-cli.jar
fi



# self-organizing-swarm-plug-in-modules

# for backups
# If you have jenkins backup, you'll able to restore your configurations via Backup plugin
# Following this way:

if [ ! -d "/usr/backup/jenkins" ]
then
mkdir -p /usr/backup/jenkins /var/lib/jenkins_restore
chown jenkins:jenkins /usr/backup/jenkins /var/lib/jenkins_restore
chmod 777 /var/lib/
fi
#'sh mvn archetype:generate -DgroupId=com.maven.app -DartifactId=maven -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 -DinteractiveMode=false'
