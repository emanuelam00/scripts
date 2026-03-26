# Supports Ubuntu 24.04
#!/bin/bash

# Update package list
echo "Updating package list..."
sudo apt-get update

# Install Podman
echo "Installing Podman..."
sudo apt-get install -y podman pip podman-compose

# Verify installation
echo "Verifying Podman installation..."
podman-compose --version

if [ $? -eq 0 ]; then
    echo "Podman installed successfully!"
else
    echo "Podman installation failed."
    exit 1
fi

sudo sed -i 's/^#*\s*unqualified-search-registries = .*/unqualified-search-registries = ["docker.io"]/' /etc/containers/registries.conf
