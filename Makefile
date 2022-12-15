BIN_PATH=$(shell pwd)/bin

.PHONY: install-oc-tools

install-oc-tools:
	BIN_PATH=$(BIN_PATH) ./install-oc-tools.sh --version $(oc_full_version)
#	./install-oc-tools.sh --latest $(oc_base_version)

fmt:
	terraform fmt --recursive