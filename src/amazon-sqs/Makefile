.PHONY: build release

IMAGE ?= signadot/amazon-sqs-plugin
IMAGE_TAG ?= latest
PLATFORMS ?= linux/amd64,linux/arm64

build:
	# Build for the local platform only.
	docker build --tag $(IMAGE):$(IMAGE_TAG) .

release:
	# Build and push multi-arch manifest.
	docker buildx build --push --tag $(IMAGE):$(IMAGE_TAG) --platform $(PLATFORMS) .
