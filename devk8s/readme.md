

Need to setup Route53 hosted zone for each person.  This might be able to be
improved on so we don't need this step.


wget https://github.com/coreos/terraform-provider-ct/releases/download/v0.2.1/terraform-provider-ct-v0.2.1-"$(uname)"-amd64.tar.gz
tar xzf terraform-provider-ct-v0.2.1-"$(uname)"-amd64.tar.gz
sudo mv terraform-provider-ct-v0.2.1-"$(uname)"-amd64/terraform-provider-ct /usr/local/bin/

cat > ~/.terraformrc << PROVIDER
providers {
  ct = "/usr/local/bin/terraform-provider-ct"
}

PROVIDER

Change directories to where you git cloned this project.
`terraform init`

export KUBECONFIG=$HOME/.secrets/clusters/<CLUSTERNAME>/auth/kubeconfig
kubectl get nodes
kubectl get pods --all-namespaces


