Docker builds for Microkubes
============================

This dicrectory contains docker compose files to run Microkubes platform on docker swarm and 
build definitions for the custom Kong and Prometheus images.

We provide a script to build all Microkubes basic microkubes services and custom images.

# Run Microkubes on Docker Swarm

First make sure your node is swarm manager. If not, initialize a swarm first:

```bash
docker swarm init
```

Then generate the keys - see ```generate-keys.sh``` script in the ```keys``` directory.

Once you have the keys in the ```keys``` directory, run the script to build all Microkubes docker 
images:

```bash
./generate-keys.sh build latest
```

This would build all Microkubes images (may take a while) in the ```build``` directory.

To deploy the full platform, run:

```bash
docker stack deploy -c docker-compose.fullstack.yml microkubes
```

Confirm that all services have been deployed by running ```docker service ls```

## Deploy the basic infrastructure only

We provide a compose file to deploy only the basic infrastructure and the build upon that stack. 
You can deploy this as a docker swarm stack by running:

```bash
docker stack deploy -c docker-compose.yml microkubes
```

# Build images script

We provide a script to build all Microkubes images at once.

The script syntax:

```bash
./build-docker-images.sh <build_directory> [<images_tag>]
```

where:
* ```build_directory``` is the target directory in which to checkout the source code and from which to build the docker images.
If the direcotry does not exists, it will be created. If the build directory already has the subprojects cloned with git, then
the script will not attempt to clone the repositories and will use the existing ones. Default target direcotry is the current 
working directory.
* ```images_tag``` - the docker tag to append to the docker images. Default is ```latest``` (for example: ```microkubes/kong:latest```).