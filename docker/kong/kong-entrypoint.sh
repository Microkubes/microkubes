#!/bin/sh

function enable_kong_plugins(){
  while true; do
    is_kong_up=`curl -sSf http://localhost:8001/plugins 2>/dev/null || echo "false"` 
    if [ "$is_kong_up" != "false"  ]; then 
      # register plugin
      curl "http://localhost:8001/plugins" -d "name=prometheus"
      echo "Prometheus plugin enabled for all APIs"
      break
    fi
    echo "Kong not up yet"
    sleep 1
  done
}


echo "Waiting for migrations to complete..."
while [ "$response" != "200" ]; do
	sleep 1
	response=$(curl --write-out %{http_code} --silent --output /dev/null http://consul:8500/v1/kv/kong-migrations)
done

echo "Migrations complete."

DNS_SERVER_IP=""
if [ -n "$KONG_DNS_SERVER_NAME" ]; then
  DNS_SERVER_IP=`dig +short "$KONG_DNS_SERVER_NAME"`
  if [ -z "$DNS_SERVER_IP" ]; then
    echo "DNS Server $KONG_DNS_SERVER_NAME not resolved"
    exit 1
  fi
fi

if [ -n "$KONG_DNS_SERVER_PORT" ]; then
  DNS_SERVER_IP="$DNS_SERVER_IP:$KONG_DNS_SERVER_PORT"
fi

if [ -n "$DNS_SERVER_IP" ]; then
  echo "Setting DNS resolver to: $DNS_SERVER_IP"
  export KONG_DNS_RESOLVER="$DNS_SERVER_IP"
fi

# Register plugins
enable_kong_plugins &

# Run anything here
exec "$@"
