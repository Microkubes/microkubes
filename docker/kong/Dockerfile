FROM kong:0.14.1-alpine

RUN apk --no-cache add curl bind-tools

COPY ./kong-entrypoint.sh /
COPY ./migrations.sh /migrations.sh
RUN chmod +x /kong-entrypoint.sh
COPY ./kong.config /etc/kong/kong.config

ENTRYPOINT ["/kong-entrypoint.sh"]

ENV KONG_NGINX_DAEMON=off
ENV KONG_CONFIG_FILE=/etc/kong/kong.config

CMD ["kong", "start", "-c", "/etc/kong/kong.config", "-vv"]
