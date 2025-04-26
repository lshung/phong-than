#!/bin/bash

# Read environment variables
source /.env

# Create user if it doesn't exist
if ! id -u $USERNAME > /dev/null 2>&1; then
    useradd -m -G sudo -s /bin/bash $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
fi

# Clean up previous XRDP sessions
rm -rf /tmp/.X11-unix/* /tmp/.X*-lock

# Start services
service dbus start
service xrdp restart

# Keep container running
tail -f /dev/null
