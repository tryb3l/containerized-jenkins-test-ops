FROM alpine:3.21

RUN apk add --no-cache nginx curl openssl && \
    rm -f /etc/nginx/http.d/default.conf && \
    mkdir -p /etc/nginx/certs

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/jenkins.conf /etc/nginx/http.d/jenkins.conf

EXPOSE 80 443

CMD ["sh", "-c", "if [ ! -s /etc/nginx/certs/localhost.crt ] || [ ! -s /etc/nginx/certs/localhost.key ]; then openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/certs/localhost.key -out /etc/nginx/certs/localhost.crt -subj '/CN=localhost' -addext 'subjectAltName=DNS:localhost,IP:127.0.0.1,IP:::1' >/dev/null 2>&1; fi && exec nginx -g 'daemon off;'"]


