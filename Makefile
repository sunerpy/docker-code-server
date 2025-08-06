SHELL=/bin/bash
IMAGE_NAME = code-server
PROJECT_ROOT=$(abspath .)
SERVER_VER=$(shell awk '/^code-server/{print $$2}' package_versions.txt | sort -V -r | head -n 1 || echo "v0.0.0")
COMMIT_ID ?= $(shell git rev-parse HEAD | cut -c1-7)
# Docker 镜像仓库
DOCKER_REPO = sunerpy
DOCKER_IMAGE_FULL = $(DOCKER_REPO)/$(IMAGE_NAME)
TAG ?= $(SERVER_VER)
BUILD_TIME := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

DOCKER_FILE=Dockerfile-global
# 定义多平台
DOCKERPLATFORMS=linux/amd64


HTTP_PROXY ?=
HTTPS_PROXY ?=
NO_PROXY ?=

# 默认基础镜像
BUILD_IMAGE ?= ghcr.io/linuxserver/baseimage-ubuntu:noble

.PHONY: build-local-docker build-remote-docker push-image clean


# Docker 镜像本地构建
build-local-docker:
build-local-docker:
	@echo "Building local Docker image"
	docker buildx build \
		--file $(DOCKER_FILE) \
		--progress=plain \
		--network host \
		--platform $(DOCKERPLATFORMS) \
		--build-arg BUILD_IMAGE=$(BUILD_IMAGE) \
		--build-arg TAG=$(TAG) \
		--build-arg HTTP_PROXY=$(HTTP_PROXY) \
		--build-arg HTTPS_PROXY=$(HTTPS_PROXY) \
		--build-arg NO_PROXY=$(NO_PROXY) \
		--no-cache \
		-t $(DOCKER_IMAGE_FULL):$(TAG)-$(COMMIT_ID) \
		-t $(DOCKER_IMAGE_FULL):latest .

# Docker 镜像远程构建(集成github action)
build-remote-docker:
build-remote-docker:
	@echo "Building remote Docker image"
	docker buildx build \
		--file $(DOCKER_FILE) \
		--progress=plain \
		--platform $(DOCKERPLATFORMS) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg BUILD_IMAGE=$(BUILD_IMAGE) \
		--build-arg TAG=$(TAG) \
		-t $(DOCKER_IMAGE_FULL):$(TAG)-$(COMMIT_ID) \
		-t $(DOCKER_IMAGE_FULL):latest \
		--push .

push-image:
	@echo "Pushing Docker image"
	docker push $(DOCKER_IMAGE_FULL):$(TAG)-$(COMMIT_ID)

clean-docker:
	@echo "Cleaning Docker cache"
	docker builder prune -f
