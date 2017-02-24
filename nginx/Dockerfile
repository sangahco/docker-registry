FROM nginx:alpine

COPY ./conf/ /etc/nginx/conf.d/
COPY ./nginx.conf.template /etc/nginx/

EXPOSE 80
EXPOSE 443

COPY ./docker-entrypoint.sh ./entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]