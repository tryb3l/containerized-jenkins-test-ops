FROM alpine:latest

# Install socat
RUN apk update && \
    apk add --no-cache socat

VOLUME /var/run/docker.sock

# Expose Docker TCP port
EXPOSE 2375

# Start socat
ENTRYPOINT ["socat", "TCP-LISTEN:2375,reuseaddr,fork", "UNIX-CLIENT:/var/run/docker.sock"]