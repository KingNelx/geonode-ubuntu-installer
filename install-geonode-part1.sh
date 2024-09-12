#!/bin/bash

# Update system and install dependencies
sudo apt-get update -y
sudo apt-get install -y software-properties-common
sudo add-apt-repository universe

# Install Git and development tools
sudo apt-get install -y git-core git-buildpackage debhelper devscripts

# Install Docker dependencies
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent

# Add Docker GPG key and repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the package index and install Docker
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose

# Clean up unnecessary packages
sudo apt autoremove --purge -y

# Start Docker service
sudo service docker start

# Add the current user to the Docker group
sudo usermod -aG docker $USER

# Refresh group membership without needing to logout and login again
exec su -l $USER
