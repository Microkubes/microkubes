VERSION := $(shell git describe --tags --exact-match 2>/dev/null || echo latest)
DOCKERHUB_NAMESPACE ?= microkubes
IMAGE := ${DOCKERHUB_NAMESPACE}/kong:${VERSION}

build:
	docker build -t ${IMAGE} ./docker/kong

push: build
	docker push ${IMAGE}

run: build
	docker run -p ${ARGS} ${IMAGE}