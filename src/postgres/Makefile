.PHONY: build-image release-image release-chart

NAME ?= postgres-test
CHART_ROOT ?= ../../signadot-plugins-exp

IMAGE ?= signadot/$(NAME)-plugin
IMAGE_TAG ?= latest
PLATFORMS ?= linux/amd64,linux/arm64

build-image:
	# Build for the local platform only.
	docker build --tag $(IMAGE):$(IMAGE_TAG) .

release-image:
	# Build and push multi-arch manifest.
	docker buildx build --push --tag $(IMAGE):$(IMAGE_TAG) --platform $(PLATFORMS) .

release-chart:
	# Copy latest Helm chart into the directory tree that gets auto-published.
	rm -rf $(CHART_ROOT)/$(NAME)
	mkdir $(CHART_ROOT)/$(NAME)
	cp -r helm/* $(CHART_ROOT)/$(NAME)/
	cp -r helm/.helmignore $(CHART_ROOT)/$(NAME)/
