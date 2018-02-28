#!/usr/bin/env bash

TOKEN=$1

ADVERTISEADDRESS=$2

# kubeadm wants lowercase for DNS (as it probably should)
LB_DNS=$(echo "$3" | tr 'A-Z' 'a-z')

LOADBALANCERNAME=$4

REGION=$5

HOSTNAME="$(hostname)"

sudo apt-get update
sudo apt-get install -y apt-transport-https awscli

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y

sudo apt-get install -y docker.io jq
sudo apt-get install -y --allow-unauthenticated kubelet kubeadm kubectl kubernetes-cni

# reset kubeadm (workaround for kubelet package presence)
sudo kubeadm reset

cat >/tmp/kubeadm.yaml <<EOF
---
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
api:
  advertiseAddress: ${ADVERTISEADDRESS}
token: ${TOKEN}
cloudProvider: aws
nodeName: ${HOSTNAME}
tokenTTL: 0s
apiServerCertSANs:
- ${LB_DNS}
EOF

sudo kubeadm init --config /tmp/kubeadm.yaml

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf

# Grant the "admin" user complete access to the cluster
sudo kubectl create clusterrolebinding admin-cluster-binding --clusterrole=cluster-admin --user=admin

sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(sudo kubectl version | base64 | tr -d '\n')"

# Install the kubernetes dashboard by default
# sudo kubectl apply -f /tmp/dashboard.yaml

INSTANCE_ID=$(ec2metadata --instance-id)
# Add this machine (master) to the load balancer for external access
aws elb register-instances-with-load-balancer \
  --load-balancer-name ${LOADBALANCERNAME} \
  --instances ${INSTANCE_ID} \
  --region ${REGION}

# DASHSRC=https://raw.githubusercontent.com/kubernetes/dashboard/master
# curl -sSL $DASHSRC/src/deploy/recommended/kubernetes-dashboard.yaml | kubectl apply -f -

# curl -sSL https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml | kubectl apply -f -

