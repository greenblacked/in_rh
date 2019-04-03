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


#mysql install
package=$(rpm -qa | grep "mysql.*")
if [[ ! $package ]]
then 
    echo "Installing mysql-server"
    wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
    rpm -ivh mysql-community-release-el7-5.noarch.rpm
    yum install mysql-server -y
    systemctl start mysql
fi

# Create sql file to add new db and user
cat << EOF > /home/vagrant/mysql_sonar.sql
CREATE DATABASE sonar;
CREATE USER 'sonar'@'localhost' IDENTIFIED BY 'sonar';
GRANT ALL ON sonar.* to sonar@'localhost';
GRANT ALL PRIVILEGES ON sonar.* TO 'sonar'@'localhost' IDENTIFIED BY 'sonar';
FLUSH PRIVILEGES;
EOF

# import new db
mysql -u root < /home/vagrant/mysql_sonar.sql


# add sonar user
check_if_user_exist=$(getent passwd | grep "sonar")
if [[ ! $check_if_user_exist ]]
then
useradd sonar
fi
mkdir /opt/sonar

# install sonar
if [ ! -f "/opt/sonar/sonarqube-7.6.zip" ]
then
    echo "Downloading sonar package"
    wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.6.zip -P /opt/sonar
    unzip /opt/sonar/sonarqube-7.6.zip -d /opt/sonar
fi

# configure sonar uname and passwd
sed -i 's/#sonar.jdbc.username=/sonar.jdbc.username=sonar/g' /opt/sonar/sonarqube-7.6/conf/sonar.properties
sed -i 's/#sonar.jdbc.password=/sonar.jdbc.password=sonar/g' /opt/sonar/sonarqube-7.6/conf/sonar.properties
sed -i '/.sonar.jdbc.url=jdbc:mysql.*/s/^#//g' /opt/sonar/sonarqube-7.6/conf/sonar.properties
sed -i 's/#RUN_AS_USER=/RUN_AS_USER=sonar/g'  /opt/sonar/sonarqube-7.6/bin/linux-x86-64/sonar.sh

chown -R sonar:sonar /opt/sonar
chown -R sonar:sonar /opt/sonar

# elastic search config
sysctl -w vm.max_map_count=262144
sysctl -w fs.file-max=65536

/opt/sonar/sonarqube-7.6/bin/linux-x86-64/sonar.sh start

echo "Waiting 30sec for sonar service start"
sleep 30s

cat << EOF > /etc/systemd/system/sonar.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonar/sonarqube-7.6/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonar/sonarqube-7.6/bin/linux-x86-64/sonar.sh stop

User=sonar
Group=sonar
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable sonar.service
