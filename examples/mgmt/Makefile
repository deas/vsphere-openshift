VC_DS=DC0
VC_IMPORT_FOLDER=templates
OC_BASE_VERSION=4.11
OC_FULL_VERSION=$(OC_BASE_VERSION).9
OC_CONFIG_DIR=./openshift

.PHONY: install-oc-tools

init:
	terraform init
#   TODO: Not beautiful 	
	terraform apply -auto-approve --target local_file.install_config 
	terraform apply -auto-approve --target null_resource.ocp4_config

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
	govc import.ova --folder=$(VC_IMPORT_FOLDER) --ds=$(VC_DS) --name=rhcos-$(OC_FULL_VERSION) https://mirror.openshift.com/pub/openshift-v4/dependencies/$(OC_BASE_VERSION)/$(OC_FULL_VERSION)/rhcos-vmware.x86_64.ova

#kraken:
#	docker run --name=kraken --net=host -v /Users/alex/git/ib/ocp4/openshift/auth/kubeconfig:/root/.kube/config -v /Users/alex/git/ib/ocp4/kraken/config/config.yaml:/root/kraken/config/config.yaml -d quay.io/openshift-scale/kraken:latest