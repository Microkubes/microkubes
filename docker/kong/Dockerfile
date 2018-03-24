FROM kong:0.11.2-alpine AS plugin-build

RUN apk --no-cache add --update git lua luarocks zip

#RUN git clone https://github.com/Microkubes/kong-plugin-prometheus.git
COPY ./kong-plugin-prometheus kong-plugin-prometheus
RUN cd kong-plugin-prometheus &&\
    sed 's,git://github.com/Mashape/kong_plugin,https://github.com/Kong/kong-plugin,g' kong-plugin-prometheus-0.0.2-1.rockspec &&\ 
    sed 's/tag = "0.1.0"/-- tag = "0.1.0"/g' kong-plugin-prometheus-0.0.2-1.rockspec &&\
    luarocks make && \
    luarocks pack kong-plugin-prometheus 0.0.2-1


FROM kong:0.11.2-alpine

RUN apk --no-cache add curl bind-tools

COPY ./kong-entrypoint.sh /
RUN chmod +x /kong-entrypoint.sh
COPY ./kong.config /etc/kong/kong.config

COPY --from=plugin-build /kong-plugin-prometheus/kong-plugin-prometheus-0.0.2-1.all.rock /
RUN luarocks install kong-plugin-prometheus-0.0.2-1.all.rock &&\
    rm kong-plugin-prometheus-0.0.2-1.all.rock

ENTRYPOINT ["/kong-entrypoint.sh"]


ENV KONG_NGINX_DAEMON=off
ENV KONG_CONFIG_FILE=/etc/kong/kong.config

#CMD ["/docker-entrypoint.sh", "/usr/local/openresty/nginx/sbin/nginx", "-c", "/usr/local/kong/nginx.conf", "-p", "/usr/local/kong/" , "-vv"]
CMD ["kong", "start", "-c", "/etc/kong/kong.config", "-vv"]