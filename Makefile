
define get_version
$(shell git rev-parse --verify HEAD | sed -r 's/(.{8}).*/\1/g')
endef

TAG = $(call get_version,)
# DOCKER_SERVER ?= "556684128444.dkr.ecr.us-east-1.amazonaws.com"

# REPOSITORY = ${DOCKER_SERVER}/${NAME}
PWD = $(shell pwd)
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
NAME = $(current_dir)


build-image:
	docker build -t ${NAME}:${TAG} -f src/Dockerfile src/

raise-local: image
	./scripts/local_test/serve_local.sh ${NAME}:${TAG}
