FROM alpine:latest
LABEL maintainer="bogdan.trybel@gmail.com"

# Install required packages
RUN apk update && \
    apk add --no-cache \
    git \
    wget \
    openjdk21 \
    sudo

# Create Jenkins user
RUN addgroup -g 1000 jenkins && \
    adduser -D -h "/home/jenkins" -u 1000 -G jenkins -s /bin/sh jenkins && \
    echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set Name Servers
COPY files/resolv.conf /etc/resolv.conf