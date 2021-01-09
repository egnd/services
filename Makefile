#!make

include .env
export

MAKEFLAGS += --always-make

BUILD_VERSION=dev
REGISTRY_IMAGE_PREFIX=egnd/services
RUN_SERVICE_NAME=

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

%:
	@:

########################################################################################################################

owner: ## Reset folder owner
	sudo chown -R $$(id -u):$$(id -u) ./
	@echo "Success"

check-conflicts: ## Find git conflicts
	@if grep -rn '^<<<\<<<< ' .; then exit 1; fi
	@if grep -rn '^===\====$$' .; then exit 1; fi
	@if grep -rn '^>>>\>>>> ' .; then exit 1; fi
	@echo "All is OK"

check-todos: ## Find TODO's
	@if grep -rn '@TO\DO:' .; then exit 1; fi
	@echo "All is OK"

check-master: ## Check for latest master in current branch
	@git remote update
	@if ! git log --pretty=format:'%H' | grep $$(git log --pretty=format:'%H' -n 1 origin/master) > /dev/null; then exit 1; fi
	@echo "All is OK"

release: ## Create release archive
	@rm -rf services-$(BUILD_VERSION).zip
	@cp build/Makefile Makefile
	zip -9 -roT services-$(BUILD_VERSION).zip \
		.env.dist \
		Makefile \
		README.md \
		fluentbit/docker-compose.yml \
		elastic/docker-compose.yml \
		kibana/docker-compose.yml \
		exporters/docker-compose.yml \
		prometheus/docker-compose.yml \
		grafana/docker-compose.yml \
		proxy/docker-compose.yml
	@ls -lah services-$(BUILD_VERSION).zip

run-fluentbit:
	@$(MAKE) _compose RUN_SERVICE_NAME=fluentbit
stop-fluentbit:
	@$(MAKE) _compose-stop RUN_SERVICE_NAME=fluentbit

run-elastic:
	@$(MAKE) _compose RUN_SERVICE_NAME=elastic
stop-elastic:
	@$(MAKE) _compose-stop RUN_SERVICE_NAME=elastic

run-kibana: ## Run UI for logs
	@$(MAKE) _compose RUN_SERVICE_NAME=kibana
stop-kibana: ## Stop UI for logs
	@$(MAKE) _compose-stop RUN_SERVICE_NAME=kibana

run-exporters:
	@$(MAKE) _compose RUN_SERVICE_NAME=exporters
stop-exporters:
	@$(MAKE) _compose-stop RUN_SERVICE_NAME=exporters

run-prometheus:
	@$(MAKE) _compose RUN_SERVICE_NAME=prometheus
stop-prometheus:
	@$(MAKE) _compose-stop RUN_SERVICE_NAME=prometheus

run-grafana: ## Run UI for monitoring
	@$(MAKE) _compose RUN_SERVICE_NAME=grafana
stop-grafana: ## stop UI for monitoring
	@$(MAKE) _compose-stop RUN_SERVICE_NAME=grafana

run-proxy: ## Run http proxy
	@$(MAKE) _compose RUN_SERVICE_NAME=proxy
stop-proxy: ## Stop http proxy
	@$(MAKE) _compose-stop RUN_SERVICE_NAME=proxy

########################################################################################################################

_compose:
ifeq ($(wildcard .env),)
	cp .env.dist .env
endif
ifeq ($(wildcard $(RUN_SERVICE_NAME)/docker-compose.override.yml),)
	@cd $(RUN_SERVICE_NAME) && \
	if ls docker-compose.debug.yml > /dev/null; then ln -s docker-compose.debug.yml docker-compose.override.yml; fi
endif
	cd $(RUN_SERVICE_NAME) && \
		docker-compose --project-name=$(DC_PROJECT_NAME)_$(RUN_SERVICE_NAME) --env-file=../.env up --abort-on-container-exit --renew-anon-volumes --attach-dependencies

_compose-stop:
	cd $(RUN_SERVICE_NAME) && \
		docker-compose --project-name=$(DC_PROJECT_NAME)_$(RUN_SERVICE_NAME) --env-file=../.env down --remove-orphans --volumes
