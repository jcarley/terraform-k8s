#!/bin/bash

BASTION_BOOTSTRAP_FILE=bastion_bootstrap.sh
BASTION_BOOTSTRAP=https://s3.amazonaws.com/quickstart-reference/linux/bastion/latest/scripts/bastion_bootstrap.sh

curl -s -o $BASTION_BOOTSTRAP_FILE $BASTION_BOOTSTRAP
chmod +x $BASTION_BOOTSTRAP_FILE

# This gets us far enough in the bastion script to be useful.
apt-get -y update && apt-get -y install python-pip
pip install --upgrade pip &> /dev/null

./$BASTION_BOOTSTRAP_FILE --banner /tmp/banner_message.txt --enable true


