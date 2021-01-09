#!make

include .env
export

MAKEFLAGS += --always-make

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

%:
	@:

########################################################################################################################

owner: ## Reset folder owner
	sudo chown -R $$(id -u):$$(id -u) ./
	@echo "Success"

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

run-monitoring: run-exporters run-prometheus ## Run host and docker exporters and prometheus
stop-monitoring: stop-prometheus stop-exporters## Stop host and docker exporters and prometheus

run-logging: run-fluentbit run-elastic ## Run logs collector and logs storage
stop-logging: stop-elastic stop-fluentbit ## Stop logs collector and logs storage

run: run-logging run-kibana run-monitoring run-grafana run-proxy ## Run all services
stop: stop-proxy stop-grafana stop-monitoring stop-kibana stop-logging ## Stop all services

########################################################################################################################

_compose:
ifeq ($(wildcard .env),)
	cp .env.dist .env
endif
	cd $(RUN_SERVICE_NAME) && \
		docker-compose --project-name=$(DC_PROJECT_NAME)_$(RUN_SERVICE_NAME) --env-file=../.env up --detach

_compose-stop:
	cd $(RUN_SERVICE_NAME) && \
		docker-compose --project-name=$(DC_PROJECT_NAME)_$(RUN_SERVICE_NAME) --env-file=../.env stop
