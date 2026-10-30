FROM tecnativa/docker-socket-proxy:v0.5.0

# Prevent Apache HttpClient5 in docker-java from reusing stale keep-alive sockets
RUN sed -i 's/timeout http-keep-alive 10s/timeout http-keep-alive 10m\n    timeout tunnel 1h/' /usr/local/etc/haproxy/haproxy.cfg.template && \
    sed -i 's/default_backend dockerbackend/http-response set-header Connection close unless { status 101 }\n    default_backend dockerbackend/' /usr/local/etc/haproxy/haproxy.cfg.template

EXPOSE 2375


