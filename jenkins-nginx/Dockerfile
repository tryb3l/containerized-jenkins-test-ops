FROM alpine:latest
LABEL maintainer="bogdan.trybel@gmail.com"

# Install NGINX
RUN apk update && \
    apk add --no-cache nginx

# Remove default configuration
RUN rm /etc/nginx/http.d/default.conf

# Add custom configuration
COPY conf/jenkins.conf /etc/nginx/http.d/jenkins.conf
COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

# Run NGINX
CMD ["nginx", "-g", "daemon off;"]