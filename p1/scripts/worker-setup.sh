#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install -y curl openssh-server

sleep 30

TOKEN=$(cat /vagrant/token)
SERVER_IP="192.168.56.110"

curl -sfL https://get.k3s.io | K3S_URL=https://${SERVER_IP}:6443 K3S_TOKEN=${TOKEN} sh -