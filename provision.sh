#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 \ --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list
# GlusterFS
sudo add-apt-repository ppa:gluster/glusterfs-3.10
sudo add-apt-repository ppa:gluster/glusterfs-coreutils
sudo apt-get update
# sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual -y
sudo apt-get install docker-engine glusterfs-server glusterfs-coreutils --force-yes -y
sudo usermod -aG docker vagrant
sudo service docker start
docker version
