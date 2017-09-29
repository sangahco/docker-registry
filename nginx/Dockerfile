FROM nginx:1.12-alpine
MAINTAINER Emanuele Disco <emanuele.disco@gmail.com>

COPY ./conf.d/ /etc/nginx/conf.d/
COPY ./nginx.template.conf /etc/nginx/
COPY ./ssl/ /etc/nginx/ssl/

RUN mkdir -p /usr/share/nginx/conf.d

EXPOSE 80
EXPOSE 443

COPY ./docker-entrypoint.sh ./entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]