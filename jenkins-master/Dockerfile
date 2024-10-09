FROM alpine:latest
LABEL maintainer="bogdan.trybel@gmail.com"

# Install required packages
RUN apk update && \
    apk add --no-cache \
    openjdk17-jre \
    wget \
    zip \
    unzip \
    git \
    dos2unix \
    curl \
    tini \
    bash \
    fontconfig \
    ttf-dejavu

# Create Jenkins user and group
RUN addgroup -g 1000 jenkins && \
    adduser -D -h "/var/jenkins_home" -u 1000 -G jenkins -s /bin/sh jenkins

# Create the /usr/share/jenkins/ref/ directory
RUN mkdir -p /usr/share/jenkins/ref/

# Download Jenkins WAR file
RUN mkdir -p /usr/share/jenkins && \
    wget -q -O /usr/share/jenkins/jenkins.war http://mirrors.jenkins.io/war-stable/latest/jenkins.war

# Copy Jenkins files and set permissions
COPY jenkinsexport.tar.gz /tmp/jenkinsexport.tar.gz
COPY jenkinsdefaultsecrets.tar.gz /tmp/jenkinsdefaultsecrets.tar.gz
COPY jobs /var/jenkins_home/jobs
RUN tar -xvf /tmp/jenkinsexport.tar.gz && \
    tar -xvf /tmp/jenkinsdefaultsecrets.tar.gz && \
    rm /tmp/jenkinsexport.tar.gz && \
    rm /tmp/jenkinsdefaultsecrets.tar.gz && \
    chown -R jenkins:jenkins /var/jenkins_home

# Copy the jenkins.sh script to the correct location
COPY jenkins.sh /usr/local/bin/jenkins.sh
RUN chmod +x /usr/local/bin/jenkins.sh

# Switch to the Jenkins user
USER jenkins

# Set the entry point
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]