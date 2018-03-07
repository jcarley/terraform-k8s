#!/usr/bin/env bash

apt-get update
apt-get install -y apt-transport-https

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update -y

apt-get install -y docker.io jq
apt-get install -y --allow-unauthenticated kubelet kubeadm kubectl kubernetes-cni

kubeadm init --token $1

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

log "Setting up weave overlay network"
curl -s -o /tmp/weave.yml "https://cloud.weave.works/k8s/v1.8/net.yaml"
kubectl apply -f /tmp/weave.yml

# DASHSRC=https://raw.githubusercontent.com/kubernetes/dashboard/master
# curl -sSL $DASHSRC/src/deploy/recommended/kubernetes-dashboard.yaml | kubectl apply -f -

# curl -sSL https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml | kubectl apply -f -

