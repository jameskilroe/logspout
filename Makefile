REPO         = ${USERNAME}
NAME         = logspout
TAG          = ${CIRCLE_TAG}
IMAGE        = $(REPO)/$(NAME)
IMAGE_ARM64  = $(IMAGE):$(TAG)-arm64

build:
	docker build --pull -t $(IMAGE_ARM64) \
		--build-arg ARCH=arm64 \
		--build-arg OS=linux \
		--build-arg VERSION=$(TAG:v%=%) \
		-f Dockerfile .
	docker save -o image.tar $(IMAGE_ARM64)

publish:
	docker load -i ./image.tar
	docker push $(IMAGE_ARM64)
	export DOCKER_CLI_EXPERIMENTAL=enabled
	docker manifest create $(IMAGE):$(TAG) $(IMAGE_AMD64) $(IMAGE_ARM64)
	docker manifest annotate $(IMAGE):$(TAG) $(IMAGE_ARM64) --arch arm64 --os linux
	docker manifest push --purge $(IMAGE):$(TAG)
	docker manifest create $(IMAGE):latest $(IMAGE_AMD64) $(IMAGE_ARM64)
	docker manifest annotate $(IMAGE):latest $(IMAGE_ARM64) --arch arm64 --os linux
	docker manifest push --purge $(IMAGE):latest
