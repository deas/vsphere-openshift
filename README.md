# ocp4-vsphere - forked from ironicbadger/ocp4

This repo contains code to deploy Openshift 4 for my homelab. It focuses on UPI with vSphere 6.7u3, a full write up is available on [openshift.com](https://www.openshift.com/blog/how-to-install-openshift-4.6-on-vmware-with-upi).

## Pre-reqs

jq, govc, watch

## Usage

> * This repo *requires* Terraform 0.13 or newer
> * Install `oc tools` with `make install-oc-tools`

0. TODO .envrc
1. Configure DNS - https://blog.ktz.me/configure-unbound-dns-for-openshift-4/ - if using CoreDNS this is optional.
3. Customize `terraform.tfvars` with any relevant configuration.
4. Run `make init` to initialize
5. Run `make apply` to create the VMs and generate/install ignition configs
6. Monitor install progress with `make wait-for-bootstrap`
7. Check and approve pending CSRs with `make get-csr` and `make approve-csr`
8. Run `make bootstrap-complete` to destroy the bootstrap VM
9. Run `make wait-for-install` and wait for the cluster install to complete
10. Enjoy!
