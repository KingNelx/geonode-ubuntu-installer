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

# Increase Git buffer size to handle large clones
git config --global http.postBuffer 524288000

# Ask user for the GeoNode version to install
echo "Select GeoNode version:"
echo "1) 4.3.1"
echo "2) 4.3.x"
echo "3) 4.2.5"
echo "4) 4.2.x"
read -p "Enter the number of the version you want to install: " version_choice

# Determine the version based on user selection
case $version_choice in
    1)
        VERSION="4.3.1"
        ;;
    2)
        VERSION="4.3.x"
        ;;
    3)
        VERSION="4.2.5"
        ;;
    4)
        VERSION="4.2.x"
        ;;
    *)
        echo "Invalid choice. Defaulting to 4.2.x."
        VERSION="4.2.x"
        ;;
esac

# Check if the version URL is accessible
REPO_URL="https://github.com/GeoNode/geonode.git"
VERSION_URL="$REPO_URL -b $VERSION"

echo "Checking if the version $VERSION exists..."

# Perform HTTP check using curl
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" -L "$REPO_URL")

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "Version $VERSION is valid. Cloning repository..."
    
    # Clone the GeoNode repository with the selected version
    cd /opt
    git clone $REPO_URL -b $VERSION geonode

    # Run the Python script to create the env file
    python3 create-envfile.py

    # Pull the necessary Docker images and start GeoNode services
    cd /opt/geonode
    docker-compose -f docker-compose.yml pull
    docker-compose -f docker-compose.yml up -d

    # Optional: Update GeoNode if necessary
    cd /opt/geonode
    git pull origin $VERSION

    # Optional: ensure current user gets the updated group permissions immediately
    exec su -l $USER
else
    echo "Error: Version $VERSION is not available (HTTP Status $HTTP_STATUS). Please check your selection or internet connection."
    exit 1
fi
