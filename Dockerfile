FROM python:2.7
MAINTAINER Matthieu Gouel <matthieu.gouel@gmail.com>

# Software version management
ENV NGINX_VERSION=1.13.12-1~stretch
ENV GUNICORN_VERSION=19.7.1
ENV GEVENT_VERSION=1.2.2

# Environment setting
ENV APP_ENVIRONMENT production

# Flask demo application
COPY ./app /app
RUN pip install -r /app/requirements.txt

# System packages installation
RUN echo "deb http://nginx.org/packages/mainline/debian/ stretch nginx" >> /etc/apt/sources.list
RUN wget https://nginx.org/keys/nginx_signing.key -O - | apt-key add -
RUN apt-get update && apt-get install -y nginx=$NGINX_VERSION supervisor\
&& rm -rf /var/lib/apt/lists/*

# Nginx configuration
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/nginx.conf

# Supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY gunicorn.conf /etc/supervisor/conf.d/gunicorn.conf

# Gunicorn installation
RUN pip install gunicorn==$GUNICORN_VERSION gevent==$GEVENT_VERSION

# Gunicorn default configuration
COPY gunicorn.config.py /app/gunicorn.config.py

WORKDIR /app

EXPOSE 80 443

CMD ["/usr/bin/supervisord"]
