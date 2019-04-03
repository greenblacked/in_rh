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

#create new user with password
adminPassword=$(cat /var/lib/jenkins/secrets/initialAdminPassword) 
echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("admin", "admin")' | java -jar /home/vagrant/jenkins-cli.jar -auth admin:$adminPassword -s http://epm-jmaster1:8080/ groovy =

# # Check cli
java -jar jenkins-cli.jar -s http://epm-jmaster1:8080 -auth admin:admin

Install plugins:
jenkins_plugins=(
ace-editor
antisamy-markup-formatter
ant
apache-httpcomponents-client-4-api
artifactory
authentication-tokens
backup
blueocean-autofavorite
blueocean-bitbucket-pipeline
blueocean-commons
blueocean-config
blueocean-core-js
blueocean-dashboard
blueocean-display-url
blueocean-events
blueocean-github-pipeline
blueocean-git-pipeline
blueocean-i18n
blueocean-jira
blueocean
blueocean-jwt
blueocean-personalization
blueocean-pipeline-api-impl
blueocean-pipeline-editor
blueocean-pipeline-scm-api
blueocean-rest-impl
blueocean-rest
blueocean-web
bouncycastle-api
branch-api
build-timeout
chucknorris
cloudbees-bitbucket-branch-source
cloudbees-folder
command-launcher
config-file-provider
credentials-binding
credentials
display-url-api
docker-commons
docker-workflow
durable-task
email-ext
emailext-template
external-monitor-job
favorite
git-client
github-api
github-branch-source
github
git
gitlab-plugin
git-server
gradle
greenballs
handlebars
handy-uri-templates-2-api
htmlpublisher
ivy
jackson2-api
javadoc
jdk-tool
jenkins-design-language
jira
jquery-detached
jquery
jquery-ui
jsch
junit
ldap
lockable-resources
mailer
mapdb-api
matrix-auth
matrix-project
maven-plugin
mercurial
momentjs
pam-auth
pipeline-build-step
pipeline-github-lib
pipeline-graph-analysis
pipeline-input-step
pipeline-milestone-step
pipeline-model-api
pipeline-model-declarative-agent
pipeline-model-definition
pipeline-model-extensions
pipeline-rest-api
pipeline-stage-step
pipeline-stage-tags-metadata
pipeline-stage-view
plain-credentials
plugins
pubsub-light
resource-disposer
role-strategy
scm-api
script-security
sonargraph-integration
sonargraph-plugin
sonar
sse-gateway
ssh-credentials
ssh-slaves
structs
subversion
swarm
timestamper
token-macro
variant
windows-slaves
workflow-aggregator
workflow-api
workflow-basic-steps
workflow-cps-global-lib
workflow-cps
workflow-durable-task-step
workflow-job
workflow-multibranch
workflow-scm-step
workflow-step-api
workflow-support
ws-cleanup
zap
zapper
zap-pipeline
)

java -jar jenkins-cli.jar -s http://epm-jmaster:8080 -auth admin:admin install-plugin "${jenkins_plugins[@]}" -restart

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
