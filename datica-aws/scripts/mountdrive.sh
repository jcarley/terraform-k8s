#!/usr/bin/env bash

sudo mkfs -t ext4 $1
sudo mkdir -p $2
sudo mount $1 $2
sudo openssl rand -out $2/sample00.txt -base64 $(( 2**25 * 3/4 ))
sudo openssl rand -out $2/sample01.txt -base64 $(( 2**26 * 3/4 ))
sudo openssl rand -out $2/sample02.txt -base64 $(( 2**27 * 3/4 ))
sudo openssl rand -out $2/sample03.txt -base64 $(( 2**28 * 3/4 ))
sudo openssl rand -out $2/sample04.txt -base64 $(( 2**29 * 3/4 ))
sudo openssl rand -out $2/sample05.txt -base64 $(( 2**30 * 3/4 ))

