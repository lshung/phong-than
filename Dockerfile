# Use latest Ubuntu as base image
FROM ubuntu:latest

# Install required packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xorg \
    dbus-x11 \
    x11-xserver-utils \
    xrdp \
    sudo \
    nano \
    firefox \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure xrdp with custom resolution
RUN sed -i 's/port=3389/port=3390/g' /etc/xrdp/xrdp.ini && \
    echo "xfce4-session" > /etc/skel/.xsession && \
    echo "startxfce4" > /etc/xrdp/startwm.sh && \
    echo "xrandr --output Virtual-1 --mode 1600x900" >> /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh

# Copy env and start.sh
COPY env /.env
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose RDP port
EXPOSE 3390

# Start script
CMD ["/start.sh"]
