#!make

include .env
export

MAKEFLAGS += --always-make

BUILD_VERSION=devel
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

release: ## Create release archive @TODO:
	zip -9 -roTj release-$(BUILD_VERSION).zip README.md
	@ls -lah release-$(BUILD_VERSION).zip

run-logging:
	@$(MAKE) _compose RUN_SERVICE_NAME=logging
stop-logging:
	@$(MAKE) _compose-stop RUN_SERVICE_NAME=logging
run-elastic:
	@$(MAKE) _compose RUN_SERVICE_NAME=elastic
stop-elastic:
	@$(MAKE) _compose-stop RUN_SERVICE_NAME=elastic
run-kibana:
	@$(MAKE) _compose RUN_SERVICE_NAME=kibana
stop-kibana:
	@$(MAKE) _compose-stop RUN_SERVICE_NAME=kibana

run-monitoring:
	@$(MAKE) _compose RUN_SERVICE_NAME=monitoring
stop-monitoring:
	@$(MAKE) _compose-stop RUN_SERVICE_NAME=monitoring
run-prometheus:
	@$(MAKE) _compose RUN_SERVICE_NAME=prometheus
stop-prometheus:
	@$(MAKE) _compose-stop RUN_SERVICE_NAME=prometheus
run-grafana:
	@$(MAKE) _compose RUN_SERVICE_NAME=grafana
stop-grafana:
	@$(MAKE) _compose-stop RUN_SERVICE_NAME=grafana

run-proxy:
	@$(MAKE) _compose RUN_SERVICE_NAME=proxy
stop-proxy:
	@$(MAKE) _compose-stop RUN_SERVICE_NAME=proxy

########################################################################################################################

_compose:
ifeq ($(wildcard $(RUN_SERVICE_NAME)/docker-compose.override.yml),)
	@cd $(RUN_SERVICE_NAME) && \
	if ls docker-compose.debug.yml > /dev/null; then ln -s docker-compose.debug.yml docker-compose.override.yml; fi
endif
	cd $(RUN_SERVICE_NAME) && \
		docker-compose --project-name=$(DC_PROJECT_NAME) --env-file=../.env up --abort-on-container-exit --renew-anon-volumes --attach-dependencies

_compose-stop:
ifeq ($(wildcard .env),)
	cp .env.dist .env
endif
	cd $(RUN_SERVICE_NAME) && \
		docker-compose --project-name=$(DC_PROJECT_NAME) --env-file=../.env down --remove-orphans --volumes
