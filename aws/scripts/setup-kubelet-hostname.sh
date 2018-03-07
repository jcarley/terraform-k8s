#!/bin/bash

set -o verbose
set -o errexit
set -o nounset
set -o pipefail

# set the hostname
HN="$(hostname -f)"

# Setting --hostname-override is a workaround for https://github.com/kubernetes/kubeadm/issues/653
# Setting --cloud-provider is a workaround for https://github.com/kubernetes/kubeadm/issues/620
/bin/cat > /tmp/10-hostname.conf <<EOF
[Service]
Environment="KUBELET_EXTRA_ARGS= --hostname-override=${HN} --cloud-provider=aws"
EOF


sudo mkdir -p /etc/systemd/system/kubelet.service.d
sudo mv /tmp/10-hostname.conf /etc/systemd/system/kubelet.service.d/10-hostname.conf
sudo systemctl daemon-reload

