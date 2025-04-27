#!/bin/bash

# Read environment variables
source /.env

# Create user if it doesn't exist
if ! id -u $USERNAME > /dev/null 2>&1; then
    useradd -m -G sudo -s /bin/bash $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

    # Initialize Wine for the user (only on first run)
    sudo -u $USERNAME env WINEPREFIX=/home/$USERNAME/.wine WINEARCH=win32 wine wineboot --init && \
    sudo -u $USERNAME winetricks -q corefonts
fi

PT_DIR=/home/"$USERNAME"/PhongThan
mkdir -p "$PT_DIR"
chown -R "$USERNAME:$USERNAME" "$PT_DIR"
cd "$PT_DIR"
# Download autoupdate.zip
if [ ! -f autoupdate.zip ]; then
    sudo -u $USERNAME wget http://download.zing.vcdn.vn/download/fs3/fs3new/autoupdate.zip
    sudo -u $USERNAME unzip autoupdate.zip
fi
# Install wine-mono
if [ ! -f wine-mono-8.1.0-x86.msi ]; then
    sudo -u $USERNAME wget https://dl.winehq.org/wine/wine-mono/8.1.0/wine-mono-8.1.0-x86.msi
    sudo -u $USERNAME wine msiexec -i wine-mono-8.1.0-x86.msi
fi
# Install wine-gecko
if [ ! -f wine-gecko-2.47.4-x86.msi ]; then
    sudo -u $USERNAME wget https://dl.winehq.org/wine/wine-gecko/2.47.4/wine-gecko-2.47.4-x86.msi
    sudo -u $USERNAME wine msiexec -i wine-gecko-2.47.4-x86.msi
fi

# Clean up previous XRDP sessions
rm -rf /tmp/.X11-unix/* /tmp/.X*-lock

# Start services
service dbus start
service xrdp restart

# Keep container running
tail -f /dev/null
