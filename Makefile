
OS := ${shell uname}

ifeq (${OS}, Linux)
	OS := linux
endif

ifeq (${OS}, Darwin)
	OS := darwin
endif

ARCH := ${shell arch}

ifeq (${ARCH}, x86_64)
	ARCH := amd64
endif

ARGOCD_VAULT_PLUGIN = ${shell which asdfaf}
ARGOCD_VAULT_PLUGIN_VERSION := "1.12.0"

.PHONY: install install-argocd-vault-plugin asdf-install

install-argocd-vault-plugin:
ifeq (${ARGOCD_VAULT_PLUGIN}, )
	@echo "Installing argocd-vault-plugin@${ARGOCD_VAULT_PLUGIN_VERSION}"
	@curl -Lo argocd-vault-plugin https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v${ARGOCD_VAULT_PLUGIN_VERSION}/argocd-vault-plugin_${ARGOCD_VAULT_PLUGIN_VERSION}_${OS}_${ARCH}
	@chmod +x argocd-vault-plugin
	@sudo mv argocd-vault-plugin /usr/local/bin
endif

asdf-install:
	@asdf install

install: asdf-install install-argocd-vault-plugin