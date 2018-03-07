To generate the needed passwordless ssh key run the following command.

### Creating a ssh key
    ssh-keygen -q -t rsa -f ~/.ssh/terraform -N '' -C terraform
    ssh-add ~/.ssh/terraform


## Add public key to your DigitalOcean ssh keys
    cat ~/.ssh/terraform.pub | pbcopy


Next run terraform init to initialize and download the Terraform AWS provider.

Run with following command:

    terraform plan \
      -out "./aws.tfplan" \
      -var "key_name=terraform" \
      -var "public_key_path=$HOME/.ssh/terraform.pub" \
      -var "aws_access_key=$AWS_ACCESS_KEY_ID" \
      -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY"

    terraform apply ./aws.tfplan

    terraform plan -destroy \
      -out "./aws.tfplan" \
      -var "key_name=terraform" \
      -var "public_key_path=$HOME/.ssh/terraform.pub" \
      -var "aws_access_key=$AWS_ACCESS_KEY_ID" \
      -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY"


### Debugging snippets

journalctl -xeu kubelet

kubectl Cheat Sheet
https://kubernetes.io/docs/reference/kubectl/cheatsheet/

verify the cgroup driver dockerd is using
docker info | grep -i cgroup
