To generate the needed passwordless ssh key run the following command.

### Creating a ssh key
    ssh-keygen -q -t rsa -f ~/.ssh/digitalocean -N '' -C digitalocean
    ssh-add ~/.ssh/digitalocean


## Add public key to your DigitalOcean ssh keys
    cat ~/.ssh/digitalocean.pub | pbcopy


Next run terraform init to initialize and download the Terraform DigitalOcean
provider.
