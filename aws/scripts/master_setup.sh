#!/usr/bin/env bash

set -o verbose
set -o errexit
set -o nounset
set -o pipefail

log() {
  echo "===> $1"
}

export DEBIAN_FRONTEND=noninteractive

TOKEN=$1

ADVERTISEADDRESS=$2

# kubeadm wants lowercase for DNS (as it probably should)
LB_DNS=$(echo "$3" | tr 'A-Z' 'a-z')

LOADBALANCERNAME=$4

REGION=$5

HOSTNAME="$(hostname -f)"

CLUSTERINFOBUCKET=com.datica.jcarley/k8s/latest

KUBERNETESVERSION=v1.9.3

WEAVE_NET_RELEASE_TAG="v2.2.0"

sudo apt-get update
sudo apt-get install -y apt-transport-https awscli

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y

sudo apt-get install -y docker.io jq
sudo apt-get install -y --allow-unauthenticated kubelet kubeadm kubectl kubernetes-cni

## Install `weave` command and DaemonSet manifest YAML
sudo curl --silent --location \
  "https://github.com/weaveworks/weave/releases/download/${WEAVE_NET_RELEASE_TAG}/weave" \
  --output /usr/bin/weave

sudo chmod 755 /usr/bin/weave

sudo curl --silent --location \
  "https://cloud.weave.works/k8s/net?v=${WEAVE_NET_RELEASE_TAG}&k8s-version=${KUBERNETESVERSION}" \
  --output /etc/weave-net.yaml

# reset kubeadm (workaround for kubelet package presence)
sudo kubeadm reset

cat >/tmp/kubeadm.yaml <<EOF
---
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
token: ${TOKEN}
cloudProvider: aws
kubernetesVersion: ${KUBERNETESVERSION}
nodeName: ${HOSTNAME}
tokenTTL: 0s
apiServerCertSANs:
- ${LB_DNS}
EOF

log "Running kubeadm init ..."
sudo kubeadm init --config /tmp/kubeadm.yaml

# And for local debugging, set up ~/.kube/config for the main user account on
# the master.
log "Coping for local debugging"
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config

log "Uploading cluster-info to s3 bucket ..."
sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf \
  get cm -n kube-public cluster-info -o \
  jsonpath={.data.kubeconfig} | aws s3 cp - s3://${CLUSTERINFOBUCKET}/cluster-info.yaml

# Grant the "admin" user complete access to the cluster
sudo kubectl create clusterrolebinding admin-cluster-binding --clusterrole=cluster-admin --user=admin --kubeconfig=/etc/kubernetes/admin.conf

log "Setting up weave overlay network"
curl -s -o /tmp/weave.yml "https://cloud.weave.works/k8s/v1.8/net.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"
sudo kubectl apply -f /tmp/weave.yml

# Install the kubernetes dashboard by default
log "Installing the kubernetes dashboard"
sudo kubectl apply -f /tmp/dashboard.yaml

# Set up the network policy blocking the AWS metadata endpoint from the default namespace.
log "Setting up the default storage class"
sudo kubectl apply -f /tmp/default.storageclass.yaml

# Set up the network policy blocking the AWS metadata endpoint from the default namespace.
log "Applying the networking policy"
sudo kubectl apply -f /tmp/network-policy.yaml

INSTANCE_ID=$(ec2metadata --instance-id)
# Add this machine (master) to the load balancer for external access
log "Registering with the ELB"
aws elb register-instances-with-load-balancer \
  --load-balancer-name ${LOADBALANCERNAME} \
  --instances ${INSTANCE_ID} \
  --region ${REGION}

# Use kubeadm's kubeconfig command to grab a client-cert-authenticated
# kubeconfig file for administrative access to the cluster.
KUBECONFIG_OUTPUT=/home/ubuntu/kubeconfig

# TODO(@chuckha): --apiserver-advertise-address is resolved to an IP address.
# We don't want this to happen because we need to use the ELB load balancer as the
# api server address.
# Instead we set the server by hand.
log "Outputting config to changing API Server advertise address to the ELB"
sudo kubeadm alpha phase kubeconfig user \
  --client-name admin \
  --apiserver-advertise-address "${LB_DNS}" \
  >$KUBECONFIG_OUTPUT

# This line sets the generated kubeconfig file's api server address to our loadbalancer.
# This should be removed if kubeadm supports non-ip advertise addresses.
log "Setting api server address to ELB"
KUBECONFIG="${KUBECONFIG_OUTPUT}" sudo kubectl config set-cluster kubernetes --server="https://${LB_DNS}"
chown ubuntu:ubuntu $KUBECONFIG_OUTPUT
chmod 0600 $KUBECONFIG_OUTPUT



