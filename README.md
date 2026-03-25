# Ubuntu Static IP & Hostname Setup Script

This repository contains a Bash script designed to automate the transition from a DHCP-based (or Cloud-Init managed) network configuration to a **fixed static IP** and a custom hostname on Ubuntu systems.

## 🚀 Overview

The script performs the following actions:

1. **Prompts** for a new system hostname.

2. **Detects** the current active network interface, IP address (with CIDR), and Gateway.
 
3. **Disables** Cloud-Init network management to prevent configuration overrides.

4. **Migrates** the default Netplan configuration to a static setup using the detected parameters.    
5. **Applies** the changes immediately.


## 🛠️ Installation & Setup

## 1. Upload the Script

Upload `setup_network.sh` to your server. It is recommended to place it in `/usr/local/bin/` for system-wide access.

Bash

```
sudo mv setup_network.sh /usr/local/bin/setup_network.sh
sudo chmod +x /usr/local/bin/setup_network.sh
```

## 2. Configure "Trigger on First Login"

To ensure the script runs automatically the first time a user logs in (and only once), follow these steps to add a "Run Once" flag.

1. Open your user's profile:

	Bash

```
nano ~/.profile
```

2. Append the following block to the end of the file:

	Bash

```
# Check if the initial setup has been run before
if [ ! -f ~/.initial_setup_done ]; then
   echo "Starting one-time system configuration..."
   sudo /usr/local/bin/setup_network.sh

  # Create the flag file so this doesn't run again
  touch ~/.initial_setup_done
fi
```

3. Save and exit (`Ctrl+X`, `Enter`, `y`).


## 📋 How it Works

When you log in for the first time:

- The `.profile` checks for the existence of `~/.initial_setup_done`.

- If not found, it triggers `setup_network.sh`.

- You will be prompted for a **hostname**.

- The script automatically grabs your current IP (e.g., `192.168.10.206/24`) so you don't lose connectivity.

- It writes a new Netplan config to `/etc/netplan/00-installer-config.yaml`.

- It creates the "flag" file so you are never prompted again on subsequent logins.


## ⚠️ Important Notes

- **Sudo Privileges:** The script requires `sudo` to modify system files and network stacks.

- **SSH Connectivity:** Because the script sets the static IP to your **current** active IP, your SSH session should remain active. However, a brief flicker may occur during `netplan apply`.

- **Manual Reset:** If you need to run the setup again, simply delete the flag file: `rm ~/.initial_setup_done`


---

## Script Source: `setup_network.sh`

The script included in this repo uses `ip route` and `awk` to ensure high accuracy in detecting environment variables without manual input.