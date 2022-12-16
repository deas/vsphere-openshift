# OKD_BASE_VERSION=4.11
# OKD_FULL_VERSION=$(OC_BASE_VERSION).9
OKD_FULL_VERSION=4.11.0-0.okd-2022-12-02-145640
OKD_CONFIG_DIR=./openshift

OC_BASE_VERSION=4.11
OC_FULL_VERSION=$(OC_BASE_VERSION).9
OC_CONFIG_DIR=./openshift

BIN_PATH=$(shell pwd)/bin

.PHONY: install-oc-tools

install-oc-tools:
	BIN_PATH=$(BIN_PATH) ./install-oc-tools.sh --version $(OC_FULL_VERSION)
#	./install-oc-tools.sh --latest $(OC_BASE_VERSION)

install-okd-tools:
	BIN_PATH=$(BIN_PATH) ./install-okd-tools.sh --version $(OKD_FULL_VERSION)

show-okd-versions:
	git ls-remote --sort='v:refname' --tags https://github.com/okd-project/okd

fmt:
	terraform fmt --recursive