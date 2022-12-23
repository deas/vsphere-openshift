VC_DS=LocalDS_0
VC_IMPORT_FOLDER=templates
OC_CONFIG_DIR=./openshift
OS_NAME=fcos
OS_FULL_VERSION=37.20221127.3.0
OS_IMG_URL=https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/$(OS_FULL_VERSION)/x86_64/fedora-coreos-$(OS_FULL_VERSION)-vmware.x86_64.ova
# OS_NAME=rhcos
# RHCOS_BASE_VERSION=4.11
# RHCOS_FULL_VERSION=$(RHCOS_BASE_VERSION).9
# OS_IMG_URL=https://mirror.openshift.com/pub/openshift-v4/dependencies/$(RHCOS_BASE_VERSION)/$(RHCOS_FULL_VERSION)/rhcos-vmware.x86_64.ova

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
	oc --kubeconfig $(OC_CONFIG_DIR)/auth/kubeconfig get nodes && echo "" && \
	oc --kubeconfig $(OC_CONFIG_DIR)/auth/kubeconfig get co && echo "" && \
	oc --kubeconfig $(OC_CONFIG_DIR)/auth/kubeconfig get csr

# lazy because it auto approves CSRs - not production suitable!
lazy-install:
	oc --kubeconfig $(OC_CONFIG_DIR)/auth/kubeconfig get nodes && echo "" && \
	oc --kubeconfig $(OC_CONFIG_DIR)/auth/kubeconfig get co && echo "" && \
	oc --kubeconfig $(OC_CONFIG_DIR)/auth/kubeconfig get csr && \
	oc --kubeconfig $(OC_CONFIG_DIR)/auth/kubeconfig get csr -ojson | \
		jq -r '.items[] | select(.status == {} ) | .metadata.name' | \
		xargs oc --kubeconfig $(OC_CONFIG_DIR)/auth/kubeconfig adm certificate approve

get-co:
	oc --kubeconfig $(OC_CONFIG_DIR)/auth/kubeconfig get co

get-nodes:
	oc --kubeconfig $(OC_CONFIG_DIR)/auth/kubeconfig get nodes

get-csr:
	oc --kubeconfig $(OC_CONFIG_DIR)/auth/kubeconfig get csr

approve-csr:
	oc --kubeconfig $(OC_CONFIG_DIR)/auth/kubeconfig get csr -ojson | \
		jq -r '.items[] | select(.status == {} ) | .metadata.name' | \
		xargs oc --kubeconfig $(OC_CONFIG_DIR)/auth/kubeconfig adm certificate approve

import-ova:
	govc import.ova --folder=$(VC_IMPORT_FOLDER) --ds=$(VC_DS) --name=$(OS_NAME)-$(OC_FULL_VERSION) $(OS_IMG_URL)

#kraken:
#	docker run --name=kraken --net=host -v /Users/alex/git/ib/ocp4/openshift/auth/kubeconfig:/root/.kube/config -v /Users/alex/git/ib/ocp4/kraken/config/config.yaml:/root/kraken/config/config.yaml -d quay.io/openshift-scale/kraken:latest