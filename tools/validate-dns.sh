#!/usr/bin/env bash
# https://docs.okd.io/4.11/installing/installing_vsphere/installing-vsphere.html

set -e

domain=$1
lb_ip=$2
bootstrap_ip=$3
nameserver_ip=$4

if [ -n "$nameserver_ip" ] ; then
  dig_args="+noall +answer @${nameserver_ip}" 
else
  dig_args="+noall +answer" 
fi


# TODO: Validate with grep
echo dig ${dig_args} api.${domain}
echo dig ${dig_args} api-int.${domain}
echo dig ${dig_args} random.apps.${domain}
echo dig ${dig_args} console-openshift-console.apps.${domain}
echo dig ${dig_args} bootstrap.${domain}

echo dig ${dig_args} -x ${lb_ip}
echo dig ${dig_args} -x ${bootstrap_ip}
