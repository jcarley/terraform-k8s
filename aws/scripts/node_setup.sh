#!/usr/bin/env bash

log() {
  echo $1
}

sudo apt-get update

# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
# add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y

sudo apt-get install -y docker.io
sudo apt-get install -y --allow-unauthenticated kubelet kubeadm kubectl kubernetes-cni

log "=> Joining cluster at: "
log "====> Discovery token: ${1}"
log "====> Master Node IP: ${2}"

sudo kubeadm join --token ${1} --discovery-token-unsafe-skip-ca-verification $2:6443

