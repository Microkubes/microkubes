#!/usr/bin/env sh
echo "Running migrations"
echo "Waiting for consul to come online..."
while [ "$response" != "301" ]; do
	sleep 1
	response=$(curl --write-out %{http_code} --silent --output /dev/null http://consul:8500)
done
echo "Consul online."

response=$(curl --write-out %{http_code} --silent --output /dev/null http://consul:8500/v1/kv/kong-migrations)

if [ "$response" != "200" ]; then 
	echo "Kong migrations failed."
	kong migrations up || { echo "Error: kong migrations up failed" ; exit 42; }
	curl -X PUT -d '{"migrations": "done"}' ${CONSUL_URL}/v1/kv/kong-migrations || \
		{ echo "Error: Consul create/update key failed" ; exit $!; }
fi

echo "Migrations script done."

