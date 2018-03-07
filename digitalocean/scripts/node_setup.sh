#!/usr/bin/env bash

log() {
  echo $1
}

apt-get update

# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
# add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update -y

apt-get install -y docker.io
apt-get install -y --allow-unauthenticated kubelet kubeadm kubectl kubernetes-cni


log "=> Joining cluster at: "
log "====> Discovery token: ${1}"
log "====> Master Node IP: ${2}"

kubeadm join --token ${1} --discovery-token-unsafe-skip-ca-verification $2:6443


