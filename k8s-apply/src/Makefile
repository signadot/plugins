DOCKER ?= docker

build-docker:
	$(DOCKER) build -t signadot/k8s-apply:latest .

release-docker:
	$(DOCKER) push signadot/k8s-apply:latest
