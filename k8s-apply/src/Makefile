GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)

RELEASE_OSES ?= linux
RELEASE_ARCHES ?= amd64 arm64

DOCKER ?= docker
SHELL = /bin/bash


dev-build-docker:
	$(DOCKER) build -t signadot/k8s-apply:latest \
		--platform $(GOOS)/$(GOARCH) \
		.


build-docker:
	$(DOCKER) build -t signadot/k8s-apply:$(RELEASE_TAG)-$(GOOS)-$(GOARCH) \
		--platform $(GOOS)/$(GOARCH) \
		--provenance false \
		.

push-docker: build-docker
	$(DOCKER) push signadot/k8s-apply:$(RELEASE_TAG)-$(GOOS)-$(GOARCH)


build-release:
	for os in $(RELEASE_OSES); do \
		for arch in $(RELEASE_ARCHES); do \
			GOOS=$$os GOARCH=$$arch $(MAKE) build-docker; \
		done; \
	done;


release-images.txt:
	mkdir -p dist
	rm -f dist/release-images.txt
	for os in $(RELEASE_OSES); do \
 		for arch in $(RELEASE_ARCHES); do \
			echo signadot/k8s-apply:${RELEASE_TAG}-$$os-$$arch >> dist/release-images.txt; \
		done; \
	done;


release: check-release-tag build-release release-images.txt
	for os in $(RELEASE_OSES); do \
 		for arch in $(RELEASE_ARCHES); do \
			GOOS=$$os GOARCH=$$arch $(MAKE) push-docker; \
		done; \
	done;
	$(DOCKER) manifest create --amend signadot/k8s-apply:$(RELEASE_TAG) \
		$(shell cat dist/release-images.txt)
	$(DOCKER) manifest push signadot/k8s-apply:$(RELEASE_TAG)


check-release-tag:
ifndef RELEASE_TAG
	$(error RELEASE_TAG is not defined)
endif