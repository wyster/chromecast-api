ENV_FILE ?= .env
-include $(ENV_FILE)

REGISTRY_HOST ?=
GITEA_REPOSITORY ?=
REGISTRY_USERNAME ?=
REGISTRY_TOKEN ?=

export REGISTRY_USERNAME REGISTRY_TOKEN

# Docker image references use a registry host without a URL scheme.
REGISTRY_HOST := $(patsubst http://%,%,$(patsubst https://%,%,$(REGISTRY_HOST)))

.PHONY: publish-docker-image
publish-docker-image:
	@test -n "$(REGISTRY_HOST)" || (echo "Set REGISTRY_HOST to your container registry host" >&2; exit 1)
	@test -n "$(GITEA_REPOSITORY)" || (echo "Set GITEA_REPOSITORY to owner/repository" >&2; exit 1)
	@test -n "$$REGISTRY_USERNAME" || (echo "Set REGISTRY_USERNAME in $(ENV_FILE)" >&2; exit 1)
	@test -n "$$REGISTRY_TOKEN" || (echo "Set REGISTRY_TOKEN in $(ENV_FILE)" >&2; exit 1)
	printf '%s' "$$REGISTRY_TOKEN" | docker login "$(REGISTRY_HOST)" --username "$$REGISTRY_USERNAME" --password-stdin
	docker buildx build \
		--platform linux/arm64 \
		--push \
		--tag "$(REGISTRY_HOST)/$(GITEA_REPOSITORY):latest" \
		.
