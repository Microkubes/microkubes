#!/usr/bin/env bash

script_path="$(dirname $0)"
keys_path="$script_path/../keys"

if [ ! -d "$keys_path" ]; then
	mkdir "$keys_path"
fi

openssl req -x509 -newkey rsa:2048 -keyout "$keys_path/service.key" -out "$keys_path/service.cert" -days 365 -nodes -subj "/CN=microkubes.com"

openssl genrsa -out "$keys_path/private.pem" 2048
openssl rsa -in "$keys_path/private.pem" -outform PEM -pubout -out  "$keys_path/public.pub"

ssh-keygen -f "$keys_path/system" -t rsa -N ''
ssh-keygen -f "$keys_path/default" -t rsa -N ''
openssl rsa -in  "$keys_path/system" -pubout -out  "$keys_path/system.pub"
openssl rsa -in  "$keys_path/default" -pubout -out  "$keys_path/default.pub"