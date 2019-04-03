#!/usr/bin/env bash
yum check-update
packages=(
    tree
    mc
    git
    wget
    unzip
    java-1.8.0-openjdk-devel.x86_64
    vim
)
yum install -y "${packages[@]}"

#export java variables
cat << EOF > /etc/environment
export JAVA_HOME='/usr/lib/jvm/jre-1.8.0-openjdk'
export JRE_HOME='/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.191.b12-1.el7_6.x86_64/jre'
EOF
source /etc/environment
