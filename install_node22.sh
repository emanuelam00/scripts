#!/bin/bash

# Remove any existing Node.js packages
sudo apt-get purge -y nodejs npm
sudo apt-get autoremove -y

# Clean up any old NodeSource list
sudo rm -f /etc/apt/sources.list.d/nodesource.list

# Re-add NodeSource repo and install
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify both
node -v
npm -v