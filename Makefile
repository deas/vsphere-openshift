ds=DC0
vsphere_folder=templates
oc_base_version=4.11
oc_full_version=$(oc_base_version).9
BIN_PATH=$(shell pwd)/bin

.PHONY: install-oc-tools

install-oc-tools:
	BIN_PATH=$(BIN_PATH) ./install-oc-tools.sh --version $(oc_full_version)
#	./install-oc-tools.sh --latest $(oc_base_version)

tfinit:
	terraform init

apply:
	./generate-configs.sh
	terraform apply -auto-approve

destroy:
	terraform destroy	

remove-bootstrap:
	terraform apply -auto-approve -var 'bootstrap_complete=true'

wait-for-bootstrap:
	cd openshift; openshift-install wait-for install-complete --log-level debug

wait-for-install:
	cd openshift; openshift-install wait-for install-complete --log-level debug

check-install:
	oc --kubeconfig openshift/auth/kubeconfig get nodes && echo "" && \
	oc --kubeconfig openshift/auth/kubeconfig get co && echo "" && \
	oc --kubeconfig openshift/auth/kubeconfig get csr

# lazy because it auto approves CSRs - not production suitable!
lazy-install:
	oc --kubeconfig openshift/auth/kubeconfig get nodes && echo "" && \
	oc --kubeconfig openshift/auth/kubeconfig get co && echo "" && \
	oc --kubeconfig openshift/auth/kubeconfig get csr && \
	oc --kubeconfig openshift/auth/kubeconfig get csr -ojson | \
		jq -r '.items[] | select(.status == {} ) | .metadata.name' | \
		xargs oc --kubeconfig openshift/auth/kubeconfig adm certificate approve

get-co:
	oc --kubeconfig openshift/auth/kubeconfig get co

get-nodes:
	oc --kubeconfig openshift/auth/kubeconfig get nodes

get-csr:
	oc --kubeconfig openshift/auth/kubeconfig get csr

approve-csr:
	oc --kubeconfig openshift/auth/kubeconfig get csr -ojson | \
		jq -r '.items[] | select(.status == {} ) | .metadata.name' | \
		xargs oc --kubeconfig openshift/auth/kubeconfig adm certificate approve

import-ova:
	govc import.ova --folder=$(vsphere_folder) --ds=$(ds) --name=rhcos-$(oc_full_version) https://mirror.openshift.com/pub/openshift-v4/dependencies/$(oc_base_version)/$(oc_full_version)/rhcos-vmware.x86_64.ova

#kraken:
#	docker run --name=kraken --net=host -v /Users/alex/git/ib/ocp4/openshift/auth/kubeconfig:/root/.kube/config -v /Users/alex/git/ib/ocp4/kraken/config/config.yaml:/root/kraken/config/config.yaml -d quay.io/openshift-scale/kraken:latest