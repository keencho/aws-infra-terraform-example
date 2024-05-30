#!/bin/bash

sudo timedatectl set-timezone Asia/Seoul
sudo yum update
sudo yum install java-21-amazon-corretto-headless
sudo yum install postgresql15
sudo yum install postgresql15-server