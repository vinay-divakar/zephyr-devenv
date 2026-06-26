DOCKERHUB_USER   ?= vinaydivakar
IMAGE            ?= zephyr-devenv

NCS_VERSION      ?= v3.2.0
ZEPHYR_VERSION   ?= v4.2.0
ZEPHYR_SDK_VERSION ?= 0.17.4
WEST_VERSION     ?= 1.5.0

NCS_TAG    = $(DOCKERHUB_USER)/$(IMAGE):ncs-$(NCS_VERSION)
ZEPHYR_TAG = $(DOCKERHUB_USER)/$(IMAGE):zephyr-$(ZEPHYR_VERSION)

.PHONY: build build-ncs build-zephyr push push-ncs push-zephyr all help

help:
	@echo "Usage: make [target] [VAR=value ...]"
	@echo ""
	@echo "Targets:"
	@echo "  build-ncs     Build NCS image"
	@echo "  build-zephyr  Build vanilla Zephyr image"
	@echo "  build         Build both images"
	@echo "  push-ncs      Push NCS image to Docker Hub"
	@echo "  push-zephyr   Push vanilla Zephyr image to Docker Hub"
	@echo "  push          Push both images to Docker Hub"
	@echo "  all           Build and push both images"
	@echo ""
	@echo "Variables (current values):"
	@echo "  DOCKERHUB_USER     = $(DOCKERHUB_USER)"
	@echo "  IMAGE              = $(IMAGE)"
	@echo "  NCS_VERSION        = $(NCS_VERSION)"
	@echo "  ZEPHYR_VERSION     = $(ZEPHYR_VERSION)"
	@echo "  ZEPHYR_SDK_VERSION = $(ZEPHYR_SDK_VERSION)"
	@echo "  WEST_VERSION       = $(WEST_VERSION)"

build-ncs:
	docker build \
		--build-arg SDK_VARIANT=ncs \
		--build-arg NCS_VERSION=$(NCS_VERSION) \
		--build-arg ZEPHYR_SDK_VERSION=$(ZEPHYR_SDK_VERSION) \
		--build-arg WEST_VERSION=$(WEST_VERSION) \
		-t $(NCS_TAG) .

build-zephyr:
	docker build \
		--build-arg SDK_VARIANT=zephyr \
		--build-arg ZEPHYR_VERSION=$(ZEPHYR_VERSION) \
		--build-arg ZEPHYR_SDK_VERSION=$(ZEPHYR_SDK_VERSION) \
		--build-arg WEST_VERSION=$(WEST_VERSION) \
		-t $(ZEPHYR_TAG) .

build: build-ncs build-zephyr

push-ncs:
	docker push $(NCS_TAG)

push-zephyr:
	docker push $(ZEPHYR_TAG)

push: push-ncs push-zephyr

all: build push
