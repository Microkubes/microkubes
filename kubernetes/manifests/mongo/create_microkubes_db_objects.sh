#!/usr/bin/env bash

echo "Creating mongo users..."
mongo  -u admin -p admin --authenticationDatabase admin "$MS_USER_DB" --eval "db.createUser({user: '$MS_USER_USER', pwd: '$MS_USER_PWD', roles: [{role: 'dbOwner', db: '$MS_USER_DB'}]});"
mongo  -u admin -p admin --authenticationDatabase admin "$MS_USERPROFILE_DB" --eval "db.createUser({user: '$MS_USERPROFILE_USER', pwd: '$MS_USERPROFILE_PWD', roles: [{role: 'dbOwner', db: '$MS_USERPROFILE_DB'}]});"
mongo  -u admin -p admin --authenticationDatabase admin "$MS_APPS_MNG_DB" --eval "db.createUser({user: '$MS_APPS_MNG_USER', pwd: '$MS_APPS_MNG_PWD', roles: [{role: 'dbOwner', db: '$MS_APPS_MNG_DB'}]});"
mongo  -u admin -p admin --authenticationDatabase admin "$MS_IDP_DB" --eval "db.createUser({user: '$MS_IDP_USER', pwd: '$MS_IDP_PWD', roles: [{role: 'dbOwner', db: '$MS_IDP_DB'}]});"
mongo  -u admin -p admin --authenticationDatabase admin "$MS_AUTH_SERVER_DB" --eval "db.createUser({user: '$MS_AUTH_SERVER_USER', pwd: '$MS_AUTH_SERVER_PWD', roles: [{role: 'dbOwner', db: '$MS_AUTH_SERVER_DB'}]});"
echo "Mongo users created."
