CURRENT_DIR = $(shell pwd)
DOCKER_NAME ?= avdteam/guardicore-temp
BRANCH ?= $(shell git symbolic-ref --short HEAD)

.PHONY: help
help: ## Display help message
	@grep -E '^[0-9a-zA-Z_-]+\.*[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Build docker image
	if [ $(BRANCH) = 'master' ]; then \
      docker build --rm --pull -t $(DOCKER_NAME):latest -f $(CURRENT_DIR)/Dockerfile .;\
	else \
	  docker build --rm --pull -t $(DOCKER_NAME):$(BRANCH) -f $(CURRENT_DIR)/Dockerfile .;\
    fi

.PHONY: run
run: ## run docker image
	if [ $(BRANCH) = 'main' ]; then \
		docker run --rm -it -v $(CURRENT_DIR)/:/home/avd/projects \
			-e AVD_GIT_USER="$(shell git config --get user.name)" \
			-e AVD_GIT_EMAIL="$(shell git config --get user.email)" \
			-v /etc/hosts:/etc/hosts $(DOCKER_NAME):latest ;\
	else \
		docker run --rm -it -v $(CURRENT_DIR)/:/home/avd/projects \
			-e AVD_GIT_USER="$(shell git config --get user.name)" \
			-e AVD_GIT_EMAIL="$(shell git config --get user.email)" \
			-v /etc/hosts:/etc/hosts $(DOCKER_NAME):$(BRANCH) ;\
	fi

.PHONY: acl
acl: ## build ACL configs with AVD playbook
	docker run --rm -it -v $(CURRENT_DIR)/:/home/avd/projects \
	    -e AVD_GIT_USER="$(shell git config --get user.name)" \
		-e AVD_GIT_EMAIL="$(shell git config --get user.email)" \
	    -v /etc/hosts:/etc/hosts $(DOCKER_NAME):latest ansible-playbook /home/avd/projects/playbooks/build-configs.yml

.PHONY: acl-deploy
acl-deploy: ## build ACL configs with AVD playbook and deploy via CVP
	docker run --rm -it -v $(CURRENT_DIR)/:/home/avd/projects \
	    -e AVD_GIT_USER="$(shell git config --get user.name)" \
		-e AVD_GIT_EMAIL="$(shell git config --get user.email)" \
	    -v /etc/hosts:/etc/hosts $(DOCKER_NAME):latest ansible-playbook /home/avd/projects/playbooks/build-and-deploy.yml
