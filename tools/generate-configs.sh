#!/bin/sh
# A helper script for openshift-install

set -e

dir=$(mktemp -d --suffix -okd)
cd ${dir}
jq -r .install_config > install-config.yaml

# create kubernetes manifests
# --dir ${dir}
openshift-install create manifests --log-level debug > openshift-install-manifests.log 2>&1

# ensure masters are not schedulable
if [ `uname` = 'Linux' ] ; then
    sed -i 's/mastersSchedulable: true/mastersSchedulable: false/g' manifests/cluster-scheduler-02-config.yml
else
# macos sed will fail, this script requires `brew install gnu-sed`
    gsed -i 's/mastersSchedulable: true/mastersSchedulable: false/g' manifests/cluster-scheduler-02-config.yml
fi

## delete machines and machinesets - because terraform
rm -f openshift/99_openshift-cluster-api_worker-machineset-0.yaml
rm -f openshift/99_openshift-cluster-api_master-machines-0.yaml
rm -f openshift/99_openshift-cluster-api_master-machines-1.yaml
rm -f openshift/99_openshift-cluster-api_master-machines-2.yaml

## ignition config creation
openshift-install create ignition-configs --log-level debug  > openshift-install-ignition.log 2>&1

# echo '{"path": "'$dir'"}'

dir=$(pwd)/openshift-sandbox
cat <<EOF
{
  "bootstrap.ign" : "$(base64 -w 0 <"$dir/bootstrap.ign")",
  "worker.ign" : "$(base64 -w 0 < "$dir/worker.ign")",
  "master.ign" : "$(base64 -w 0 < "$dir/master.ign")",
  "metadata.json" : "$(base64 -w 0 < "$dir/metadata.json")",
  "auth/kubeadmin-password" : "$(base64 -w 0 < "$dir/auth/kubeadmin-password")",
  "auth/kubeconfig" : "$(base64 -w 0 < "$dir/auth/kubeconfig")"
}
EOF

rm -rf "${dir}"
# (cat $dir/bootstrap.ign)
  #openshift-sandbox/bootstrap.ign
  #openshift-sandbox/worker.ign
  #openshift-sandbox/auth/kubeadmin-password
  #openshift-sandbox/auth/kubeconfig
  #openshift-sandbox/metadata.json
  #openshift-sandbox/.openshift_install_state.json
  #openshift-sandbox/.openshift_install.log
  #openshift-sandbox/master.ign
