#!/bin/bash

# Update package list and install Python
sudo apt update
sudo apt install -y python3 python3-pip

# Create directory for GeoNode
sudo mkdir -p /opt/geonode/

# Add the current user to the www-data group
sudo usermod -aG www-data $USER

# Set ownership and permissions for the /opt/geonode directory
sudo chown -R $USER:www-data /opt/geonode/
sudo chmod -R 775 /opt/geonode/

# Clone the GeoNode repository with version 4.2.x
cd /opt
git clone https://github.com/GeoNode/geonode.git -b 3.3.3 geonode

# Run the Python script to create the env file
python3 create-envfile.py

# Pull the necessary Docker images and start GeoNode services
cd /opt/geonode
docker-compose -f docker-compose.yml pull
docker-compose -f docker-compose.yml up -d

# Update GeoNode (optional step if necessary)
cd /opt/geonode
git pull origin 4.2.x

# Optional: ensure current user gets the updated group permissions immediately
exec su -l $USER
