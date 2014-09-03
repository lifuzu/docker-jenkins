# VERSION 1.0
# DOCKER-VERSION  1.2.0
# AUTHOR:         Richard Lee <lifuzu@gmail.com>
# DESCRIPTION:    Image with Jenkins project and dependecies
# TO_BUILD:       $ sudo docker build -rm -t weimed/docker-jenkins .
# TO_RUN:         $ sudo docker run -p 8080:8080 --name jenkins weimed/docker-jenkins

FROM ubuntu:14.04

MAINTAINER Richad Lee "lifuzu@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

# Update
RUN     apt-get update
RUN     apt-get install -y wget git curl zip
#RUN     apt-get install -y --no-install-recommends supervisor
RUN     apt-get clean

# Java
# TODO: extract JAVA version
RUN     cd /tmp && \
        curl -b gpw_e24=http%3A%2F%2Fwww.oracle.com -b oraclelicense=accept-securebackup-cookie -O -L http://download.oracle.com/otn-pub/java/jdk/8u20-b26/jdk-8u20-linux-x64.tar.gz && \
        tar -zxf /tmp/jdk-8u20-linux-x64.tar.gz -C /usr/local && \
        ln -s /usr/local/jdk1.8.0_20 /usr/local/java && \
        rm /tmp/jdk-8u20-linux-x64.tar.gz

ENV     JAVA_HOME /usr/local/java
ENV     PATH $PATH:$JAVA_HOME/bin

# Install components
RUN     apt-get update
RUN     apt-get install -y maven ant ruby rbenv make
RUN     apt-get clean

# Install Jenkins
RUN     wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
RUN     echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list
RUN     apt-get update 
RUN     apt-get install -y jenkins

RUN     mkdir -p /var/jenkins_home && chown -R jenkins /var/jenkins_home
ADD     init.groovy /tmp/WEB-INF/init.groovy
RUN     cd /tmp && zip -g /usr/share/jenkins/jenkins.war WEB-INF/init.groovy
ADD     jenkins.sh /usr/local/bin/jenkins.sh
RUN     chmod +x /usr/local/bin/jenkins.sh
USER    jenkins

# TODO: supervisor to monitor the service
# Give jenkins permissions to manage the supervisor service
#RUN     echo "jenkins        ALL = NOPASSWD: ALL" >> /etc/sudoers
#USER    jenkins

# Config
#ADD     jenkins.conf /etc/supervisor/conf.d/

# VOLUME /var/jenkins_home - bind this in via -v if you want to make this persistent.
ENV     JENKINS_HOME /var/jenkins_home

# define url prefix for running jenkins behind Apache (https://wiki.jenkins-ci.org/display/JENKINS/Running+Jenkins+behind+Apache)
ENV     JENKINS_PREFIX /

# for main web interface:
EXPOSE  8080

# will be used by attached slave agents:
EXPOSE  50000

CMD ["/usr/local/bin/jenkins.sh"]
#CMD ["supervisord"]
