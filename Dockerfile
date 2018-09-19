FROM ubuntu:16.04

MAINTAINER uzzal, uzzal2k5@gmail.com

RUN apt-get update && apt-get install -y net-tools nginx
	# Set the locale

# CONFIG STANDARD ERROR LOG
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

# MODIFY NGINX TO PREVENT DISPLAY NGINX VERSION
RUN sed -i 's/# server_tokens off/server_tokens off/g' /etc/nginx/nginx.conf

# SET HEALTH CHECK
HEALTHCHECK --interval=5s \
            --timeout=5s \
            CMD curl -f http://127.0.0.1:8000 || exit 1

# EXPOSING PORTS & ENDPOINT
EXPOSE 80

STOPSIGNAL SIGTERM

ENTRYPOINT ["nginx", "-g", "daemon off;"]




