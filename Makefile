PHONY :=
.DEFAULT_GOAL := help

DOCKER_IMAGE := druidfi/docker-ssh
#DOCKER_IMAGE := jeroenpeeters/docker-ssh
DOCKER_TAG := latest
#DOCKER_TAG := 1.5.1

PHONY += build
build: ## Build the image
	docker build --no-cache --force-rm . -f Dockerfile -t ${DOCKER_IMAGE}:${DOCKER_TAG}

PHONY += down
down: ## Build the image
	docker stop $(shell docker ps -q --filter name=^/sshtest$) || true
	docker rm $(shell docker ps -q --filter name=^/sshtest$) || true
	docker stop $(shell docker ps -q --filter name=^/ubuntu$) || true
	docker rm $(shell docker ps -q --filter name=^/ubuntu$) || true

PHONY += help
help: ## List all make commands
	$(call colorecho, "\nAvailable make commands:")
	@cat $(MAKEFILE_LIST) | grep -e "^[a-zA-Z_\-]*: *.*## *" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' | sort

PHONY += push
push: ## Push the image
	docker push ${DOCKER_IMAGE}:${DOCKER_TAG}

PHONY += shell-ssh
shell-ssh: ## Login to ssh container
	docker exec -it sshtest sh

PHONY += test
test: V := v
test: ## Test image
	ssh drupal@localhost -p 2222 -${V}

PHONY += up
up: PORT := 2222:22
up: SOCK := /var/run/docker.sock:/var/run/docker.sock
up: ## Start containers
	docker run --name ubuntu -t -d ubuntu
	docker run --name sshtest -d -p ${PORT} -v ${SOCK} -e FILTERS={\"name\":[\"^/headpower.fi.docker.amazee.io$$\"]} -e SHELL_USER=drupal -e AUTH_MECHANISM=noAuth ${DOCKER_IMAGE}:${DOCKER_TAG}
	docker network connect amazeeio-network sshtest

.PHONY: $(PHONY)

define colorecho
	@tput -T xterm setaf 3
	@echo $1
	@tput -T xterm sgr0
endef
