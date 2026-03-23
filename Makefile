.DEFAULT_GOAL := help
SHELL := /bin/bash
VENV := .venv
PYTHON := $(VENV)/bin/python
PIP := $(VENV)/bin/pip

.PHONY: help venv install build deploy-dev deploy-staging deploy-production \
        delete-dev delete-staging delete-production create-env lint test

help:
	@echo "Usage:"
	@echo "  make venv              Create Python virtual environment"
	@echo "  make install           Install dev dependencies into venv"
	@echo "  make build TAG=<tag>   Build all Docker images in minikube with the given tag"
	@echo "  make deploy-dev        Deploy all services to dev environment"
	@echo "  make deploy-staging    Deploy all services to staging environment"
	@echo "  make deploy-production Deploy all services to production environment"
	@echo "  make delete-dev        Delete dev environment"
	@echo "  make delete-staging    Delete staging environment"
	@echo "  make delete-production Delete production environment"
	@echo "  make create-env ENV=<name>  Create a new virtual environment overlay"
	@echo "  make lint              Run ruff linter"
	@echo "  make test              Run tests"

$(VENV)/bin/activate:
	python3.11 -m venv $(VENV)
	$(PIP) install --upgrade pip

venv: $(VENV)/bin/activate

install: venv
	$(PIP) install -e ".[dev]"

build:
ifndef TAG
	$(error TAG is required. Usage: make build TAG=v1.2.0)
endif
	./scripts/build-images.sh $(TAG)

deploy-dev:
	./scripts/deploy-env.sh dev

deploy-staging:
	./scripts/deploy-env.sh staging

deploy-production:
	./scripts/deploy-env.sh production

delete-dev:
	./scripts/delete-env.sh dev

delete-staging:
	./scripts/delete-env.sh staging

delete-production:
	./scripts/delete-env.sh production

create-env:
ifndef ENV
	$(error ENV is required. Usage: make create-env ENV=feature-my-branch)
endif
	./scripts/create-env.sh $(ENV)

lint: venv
	$(VENV)/bin/ruff check services/

test: venv
	$(VENV)/bin/pytest tests/ -v
