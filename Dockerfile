# Use latest Ubuntu as base image
FROM ubuntu:latest

# Set up for automatic MS Core Fonts EULA acceptance
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections

# Install XFCE and XRDP
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    wget \
    gnupg2 \
    software-properties-common \
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

# Enable 32-bit architecture and update
RUN dpkg --add-architecture i386 && \
    apt-get update

# Add WineHQ repository (new method)
RUN mkdir -p /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    echo "deb [signed-by=/etc/apt/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/ubuntu/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/winehq.list

# Install Wine components
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    --install-recommends \
    wine-stable \
    winetricks \
    fonts-wine \
    ttf-mscorefonts-installer \
    wine-stable-i386 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure XRDP
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
