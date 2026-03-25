#!/bin/bash

# 1. Ask for the new hostname
read -p "Enter the desired hostname: " NEW_HOSTNAME

# 2. Set the hostname
sudo hostnamectl set-hostname "$NEW_HOSTNAME"
echo "Hostname set to $NEW_HOSTNAME"

# 3. Detect current Network Info
# Grabs the primary interface name (e.g., ens3 or eth0)
INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')
# Grabs the current IP with CIDR (e.g., 192.168.1.50/24)
CURRENT_IP=$(ip -f inet addr show "$INTERFACE" | awk '/inet / {print $2}')
# Grabs the current Gateway
GATEWAY=$(ip route | grep default | awk '{print $3}')

echo "Detected Interface: $INTERFACE"
echo "Detected IP: $CURRENT_IP"
echo "Detected Gateway: $GATEWAY"

# 4. Disable Cloud-Init Network Config
echo "Disabling Cloud-Init network management..."
sudo bash -c "cat <<EOF > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
network: {config: disabled}
EOF"

# 5. Move and create the new Netplan config
if [ -f /etc/netplan/50-cloud-init.yaml ]; then
    sudo mv /etc/netplan/50-cloud-init.yaml /etc/netplan/00-installer-config.yaml
fi

echo "Applying new Netplan configuration..."
sudo bash -c "cat <<EOF > /etc/netplan/00-installer-config.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    $INTERFACE:
      dhcp4: false
      addresses: [$CURRENT_IP]
      routes:
        - to: default
          via: $GATEWAY
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
EOF"

# 6. Apply changes
sudo netplan apply

echo "Configuration complete! Your IP is now fixed at $CURRENT_IP."