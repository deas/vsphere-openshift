VC_DS=LocalDS_0
VC_IMPORT_FOLDER=templates
OC_CONFIG_DIR=./openshift
KUBECONFIG=$(OC_CONFIG_DIR)/auth/kubeconfig
OC=oc --kubeconfig $(KUBECONFIG)
OS_NAME=fcos
OS_FULL_VERSION=37.20221127.3.0
OS_IMG_URL=https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/$(OS_FULL_VERSION)/x86_64/fedora-coreos-$(OS_FULL_VERSION)-vmware.x86_64.ova
# OS_NAME=rhcos
# RHCOS_BASE_VERSION=4.11
# RHCOS_FULL_VERSION=$(RHCOS_BASE_VERSION).9
# OS_IMG_URL=https://mirror.openshift.com/pub/openshift-v4/dependencies/$(RHCOS_BASE_VERSION)/$(RHCOS_FULL_VERSION)/rhcos-vmware.x86_64.ova
KRAKEN_IMAGE=quay.io/chaos-kubox/krkn:latest
KRAKEN_CONFIG=$(shell pwd)/../../kraken/config/config.yaml
KRAKEN_NAME=kraken
# -v <path_to_scenarios_directory>:/root/kraken/scenarios:Z
KRAKEN_ARGS=--name=$(KRAKEN_NAME) --net=host -v $(KUBECONFIG):/root/.kube/config:Z -v $(KRAKEN_CONFIG):/root/kraken/config/config.yaml:Z $(KRAKEN_IMAGE)

init:
	terraform init

apply:
	terraform apply -auto-approve

destroy:
	terraform destroy
	rm -rf $(OC_CONFIG_DIR)

remove-bootstrap:
	terraform apply -auto-approve -var 'bootstrap_complete=true'

wait-for-bootstrap:
	cd openshift; openshift-install wait-for install-complete --log-level debug

wait-for-install:
	cd openshift; openshift-install wait-for install-complete --log-level debug

check-install:
	$(OC) get nodes && echo "" && \
	$(OC) get co && echo "" && \
	$(OC) get csr

# lazy because it auto approves CSRs - not production suitable!
lazy-install:
	$(OC) get nodes && echo "" && \
	$(OC) get co && echo "" && \
	$(OC) get csr && \
	$(OC) get csr -ojson | \
		jq -r '.items[] | select(.status == {} ) | .metadata.name' | \
		xargs $(OC) adm certificate approve

get-co:
	$(OC) get co

get-nodes:
	$(OC) get nodes

get-csr:
	$(OC) get csr

approve-csr:
	$(OC) get csr -ojson | \
		jq -r '.items[] | select(.status == {} ) | .metadata.name' | \
		xargs $(OC) adm certificate approve

import-ova:
	govc import.ova --folder=$(VC_IMPORT_FOLDER) --ds=$(VC_DS) --name=$(OS_NAME)-$(OC_FULL_VERSION) $(OS_IMG_URL)

.PHONY: chaos-test
chaos-test:
    # -v <path_to_scenarios_directory>:/root/kraken/scenarios:Z
	docker run $(KRAKEN_ARGS)
	docker cp $(KRAKEN_NAME):/root/kraken/kraken.report .
	docker rm $(KRAKEN_NAME)
