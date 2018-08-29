FROM alpine:3.8 as plugin-build

ENV KONG_PLUGIN_PROMETHEUS_VERSION 0.1.1

WORKDIR /src/kong-plugin-prometheus

RUN apk --no-cache add --update git lua luarocks zip && \
    ln -s /usr/bin/luarocks-5.1 /usr/bin/luarocks

RUN git clone https://github.com/yciabaud/kong-plugin-prometheus .

RUN git checkout v${KONG_PLUGIN_PROMETHEUS_VERSION}

RUN luarocks make && \
    luarocks pack kong-plugin-prometheus ${KONG_PLUGIN_PROMETHEUS_VERSION}


FROM kong:0.14.1-alpine

ENV KONG_PLUGIN_PROMETHEUS_VERSION 0.1.1

RUN apk --no-cache add curl bind-tools

COPY ./kong-entrypoint.sh /
COPY ./migrations.sh /migrations.sh
RUN chmod +x /kong-entrypoint.sh
COPY ./kong.config /etc/kong/kong.config

COPY --from=plugin-build /src/kong-plugin-prometheus/kong-plugin-prometheus-${KONG_PLUGIN_PROMETHEUS_VERSION}-1.all.rock /
RUN luarocks install kong-plugin-prometheus-${KONG_PLUGIN_PROMETHEUS_VERSION}-1.all.rock &&\
    rm kong-plugin-prometheus-${KONG_PLUGIN_PROMETHEUS_VERSION}-1.all.rock

ENTRYPOINT ["/kong-entrypoint.sh"]


ENV KONG_NGINX_DAEMON=off
ENV KONG_CONFIG_FILE=/etc/kong/kong.config

#CMD ["/docker-entrypoint.sh", "/usr/local/openresty/nginx/sbin/nginx", "-c", "/usr/local/kong/nginx.conf", "-p", "/usr/local/kong/" , "-vv"]
CMD ["kong", "start", "-c", "/etc/kong/kong.config", "-vv"]
