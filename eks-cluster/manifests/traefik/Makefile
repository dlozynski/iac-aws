$(eval GIT_COMMIT = $(shell git rev-parse --short HEAD))

#maxmind
YOUR_LICENSE_KEY=fake_licence_key

#traefik plugin
PLUGIN_MODULE=github.com/dlozynski/traefikgeoip2
PLUGIN_GIT_REPO=git@github.com:dlozynski/traefikgoeip2.git
PLUGIN_GIT_BRANCH=main

AWS_ACCOUNT=12300004321
AWS_REGION=eu-west-1
AWS_PROFILE=default

APP_NAME=theapp
TRAEFIK_NAME=traefik
TRAEFIK_VERSION=2.7
DOCKER_BASE=$(TRAEFIK_NAME)
DOCKER_VERSION=$(GIT_COMMIT)
DOCKER_TAG=$(TRAEFIK_VERSION)-$(DOCKER_VERSION)

#ECR
DOCKER_TAG_REPO=$(AWS_ACCOUNT).dkr.ecr.eu-west-1.amazonaws.com

default: build

clean:
	rm -f ./traefik.Dockerfile

prepare:
# Database URL
	wget -O GeoLite2-City.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=$(YOUR_LICENSE_KEY)&suffix=tar.gz"

# SHA256 URL
# https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=YOUR_LICENSE_KEY&suffix=tar.gz.sha256

	tar xvzf GeoLite2-City.tar.gz --strip-components 1

Dockerfile: traefik.Dockerfile.template

	sed \
		-e "s!{{ .TraefikName }}!$(TRAEFIK_NAME)!g" \
		-e "s!{{ .TraefikVersion }}!$(TRAEFIK_VERSION)!g" \
		-e "s!{{ .Version }}!$(DOCKER_TAG)!g" \
		-e "s!{{ .GitCommit }}!$(GIT_COMMIT)!g" \
			traefik.Dockerfile.template > traefik.Dockerfile

build: Dockerfile
	DOCKER_BUILDKIT=1 docker build -f traefik.Dockerfile --no-cache \
	--ssh default=$(SSH_AUTH_SOCK) \
	-t $(DOCKER_TAG_REPO)/$(DOCKER_BASE):$(DOCKER_TAG) \
	--build-arg PLUGIN_MODULE=$(PLUGIN_MODULE) \
  	--build-arg PLUGIN_GIT_REPO=$(PLUGIN_GIT_REPO) \
  	--build-arg PLUGIN_GIT_BRANCH=$(PLUGIN_GIT_BRANCH) .

run: build
	docker run -it -p80:80 --rm $(DOCKER_TAG_REPO)/$(DOCKER_BASE):$(DOCKER_TAG)

debug: build
	docker run -it -p80:80 --rm $(DOCKER_TAG_REPO)/$(DOCKER_BASE):$(DOCKER_TAG) /bin/sh

push: auth
	docker push $(DOCKER_TAG_REPO)/$(DOCKER_BASE):$(DOCKER_TAG)

auth:
	aws ecr get-login-password --region $(AWS_REGION) --profile $(AWS_PROFILE) | docker login --username AWS --password-stdin $(DOCKER_TAG_REPO)