.PHONY: all image push pull clean

TAG ?= local
ORG ?= techservicesillinois
SHIB_IN_A_BOX_TAG=$(TAG)

IMAGE := $(ORG)/$(NAME):$(TAG)

all: image

image: .image
.image: $(SRCS)
	docker build --build-arg TAG=$(TAG) -t $(IMAGE) .
	@touch $@

push: .push
.push: image
	docker push $(IMAGE)
	@touch $@

pull:
	docker pull $(IMAGE)

clean:
	-docker rmi $(IMAGE)
	-rm -f .image .push
