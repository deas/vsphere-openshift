#!/bin/sh
set -e

dir=$(mktemp -d --suffix -okd)
cd ${dir}
jq -r .install_config > install-config.yaml


# rm -rf *.ign && \
mkdir -p auth
echo 'test' > auth/kubeconfig
echo 'test' > auth/kubeadmin-password
touch bootstrap.ign
touch master.ign
touch worker.ign
touch metadata.json

# echo '{"path": "'$dir'"}'

# dir=$(pwd)/openshift-sandbox
cat <<EOF
{
  "bootstrap.ign" : "$(cat "$dir/bootstrap.ign" | base64 -w 0)",
  "worker.ign" : "$(cat "$dir/worker.ign" | base64 -w 0)",
  "master.ign" : "$(cat "$dir/master.ign" | base64 -w 0)",
  "metadata.json" : "$(cat "$dir/metadata.json" | base64 -w 0)",
  "auth/kubeadmin-password" : "$(cat "$dir/auth/kubeadmin-password" | base64 -w 0)",
  "auth/kubeconfig" : "$(cat "$dir/auth/kubeconfig" | base64 -w 0)"
}
EOF

rm -rf "${dir}"