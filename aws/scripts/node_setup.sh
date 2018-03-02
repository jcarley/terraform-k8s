#!/usr/bin/env bash

set -o verbose
# set -o errexit
# set -o nounset
# set -o pipefail


log() {
  echo $1
}

HOSTNAME="$(hostname -f)"

CLUSTERINFOBUCKET=com.datica.jcarley/k8s/latest

sudo apt-get update
sudo apt-get install -y awscli

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

# Get the discovery file
aws s3 cp s3://${CLUSTERINFOBUCKET}/cluster-info.yaml /tmp/cluster-info.yaml

sudo kubeadm join \
  --node-name="${HOSTNAME}" \
  --token ${1} \
  --discovery-file="/tmp/cluster-info.yaml" \
  $2:6443

