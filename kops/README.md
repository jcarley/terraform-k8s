To generate the needed passwordless ssh key run the following command.

### Creating a ssh key
    ssh-keygen -q -t rsa -f ~/.ssh/terraform -N '' -C terraform
    ssh-add ~/.ssh/terraform


## Add public key to your DigitalOcean ssh keys
    cat ~/.ssh/terraform.pub | pbcopy


Next run terraform init to initialize and download the Terraform AWS provider.

