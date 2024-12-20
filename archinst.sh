#!/bin/bash

# Download and extract cachyos-repo
curl -O https://mirror.cachyos.org/cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz
cd cachyos-repo

# Run cachyos-repo setup script
sudo ./cachyos-repo.sh

# Install paru with --needed to prevent reinstallation and auto-allow dependencies
sudo pacman -S paru --noconfirm --needed

# Use paru to install the specified packages and auto-allow dependencies
paru -S --noconfirm --needed \
    cachyos-settings \
    systemd-boot-manager \
    fastfetch \
    fish \
    cachyos-hello \
    linux-cachyos \
    linux-cachyos-headers \
    linux-cachyos-nvidia-open \
    brave-bin \
    signal-desktop \
    moc-pulse \
    btop \
    cava \
    unimatrix \
    ttf-migu \
    obs-studio \
    proton-cachyos \
    proton-ge-custom-bin \
    python-pynvml \
    winetricks \
    unimatrix-git \
    caca \
    wine-cachyos \
    gwenview \
    rar \
    haruna \
    discord \
    alsa-utils

# Increase source volume by 200%
pactl set-source-volume @DEFAULT_SOURCE@ +200%

# Check if /mnt/nas exists, if not create it
if [ ! -d /mnt/nas ]; then
  sudo mkdir -p /mnt/nas
fi

# Check if /etc/samba/credentials exists, if not create it
if [ ! -d /etc/samba/credentials ]; then
  sudo mkdir -p /etc/samba/credentials
fi

# Create the Samba credentials file with the user and password if it doesn't exist
CREDENTIALS_FILE="/etc/samba/credentials/share"
if [ ! -f $CREDENTIALS_FILE ]; then
  echo -e "username=user\npassword=pass" | sudo tee $CREDENTIALS_FILE > /dev/null
  sudo chmod 600 $CREDENTIALS_FILE
fi

# Add NAS entry to /etc/fstab
echo "//192.168.1.100/NAS /mnt/nas cifs _netdev,nofail,vers=3.0,credentials=/etc/samba/credentials/share,uid=1000,gid=1000,x-systemd.automount 0 0" | sudo tee -a /etc/fstab

# Mount the NAS
sudo mount -a

# Set Fish as the default shell for all users
if ! grep -q '/usr/bin/fish' /etc/shells; then
  echo '/usr/bin/fish' | sudo tee -a /etc/shells
fi

# Change the default shell for all users
for user in $(cut -f1 -d: /etc/passwd); do
  sudo chsh -s /usr/bin/fish "$user"
done

# Copy nvoc.sh to /usr/local/bin/nvoc.sh and make it executable
sudo cp "$(dirname "$0")/nvoc.sh" /usr/local/bin/nvoc.sh
sudo chmod +x /usr/local/bin/nvoc.sh

# Copy nvoc.service to /etc/systemd/system/nvoc.service
sudo cp "$(dirname "$0")/nvoc.service" /etc/systemd/system/nvoc.service

# Reload systemd to apply the new service file
sudo systemctl daemon-reload

# Enable and start the nvoc service
sudo systemctl enable --now nvoc.service

# Files to modify
files=("/etc/systemd/system.conf" "/etc/systemd/user.conf")

# Modify DefaultTimeoutStopSec and DefaultTimeoutAbortSec in both files
for file in "${files[@]}"; do
  # Modify DefaultTimeoutStopSec
  sudo sed -i 's/^#DefaultTimeoutStopSec=.*/DefaultTimeoutStopSec=3s/' "$file"
  sudo sed -i 's/^DefaultTimeoutStopSec=.*/DefaultTimeoutStopSec=3s/' "$file"

  # Modify DefaultTimeoutAbortSec
  sudo sed -i 's/^#DefaultTimeoutAbortSec=.*/DefaultTimeoutAbortSec=3s/' "$file"
  sudo sed -i 's/^DefaultTimeoutAbortSec=.*/DefaultTimeoutAbortSec=3s/' "$file"
done

# Reload systemd configuration to apply changes
sudo systemctl daemon-reload

# Print message about cachyos sdboot-manage commands
echo "Must run to enable cachyos sdboot-manage commands"
echo "sudo sdboot-manage setup"
echo "sudo sdboot-manage remove"
echo "sudo sdboot-manage gen"
echo "After this you can Paru -Rns linux linux-headers and keep CachyOS Kernel if you wish"
