#!/usr/bin/env bash

yum check-update
packages=(
    nano
    tree
    mc
    git
    wget
    unzip
    java-1.8.0-openjdk-devel.x86_64
    vim
    sshpass.x86_64
)
yum install -y "${packages[@]}"


#export java variables
cat << EOF > /etc/environment
export JAVA_HOME='/usr/lib/jvm/jre-1.8.0-openjdk'
export JRE_HOME='/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.191.b12-1.el7_6.x86_64/jre'
export PATH=/opt/apache-maven-3.6.0/bin:$PATH
EOF
source /etc/environment

# Install maven
if [ ! -f "apache-maven-3.6.0-bin.zip" ]
then
wget http://apache.volia.net/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.zip
unzip apache-maven-3.6.0-bin.zip -d /opt/
fi

# connect agent to master
mkdir "$(hostname)"
if [ ! -f "swarm-client-3.9.jar*" ]
then
wget https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.9/swarm-client-3.9.jar
fi

java -jar swarm-client-3.9.jar -master http://epm-jmaster:8080 -username admin -password admin -description "$(hostname)" -disableClientsUniqueId -executors 5 -fsroot "$(hostname)" -labels "$(hostname)" -name "$(hostname)" &
