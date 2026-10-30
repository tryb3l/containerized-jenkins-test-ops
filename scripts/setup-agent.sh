#!/usr/bin/env sh
set -eu

# Install system packages from the base image's native Alpine repository
apk add --no-cache \
    docker-cli \
    git \
    curl \
    bash \
    tini \
    ca-certificates

# Install OpenJDK 25 JRE from native repo (Alpine 3.23+) or fallback to v3.23 community for Alpine 3.21
if ! apk add --no-cache openjdk25-jre-headless 2>/dev/null; then
    apk add --no-cache -X https://dl-cdn.alpinelinux.org/alpine/v3.23/community openjdk25-jre-headless
fi

deluser --remove-home node 2>/dev/null || true
addgroup -g 1000 jenkins
adduser -D -h "/home/jenkins" -u 1000 -G jenkins -s /bin/bash jenkins
mkdir -p /home/jenkins/workspace
chown -R jenkins:jenkins /home/jenkins


