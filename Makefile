.PHONY: build

IMAGE_NAME="bdbstudios/centos-base"

build:
	docker build -t ${IMAGE_NAME} .
