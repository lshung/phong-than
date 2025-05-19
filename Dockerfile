# Sử dụng Ubuntu mới nhất làm base image
FROM ubuntu:latest

# Cấu hình tự động chấp nhận EULA cho MS Core Fonts
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections

# Cài đặt XFCE và XRDP
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
    tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Cấu hình múi giờ Việt Nam
RUN ln -fs /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Bật kiến trúc 32-bit và cập nhật apt
RUN dpkg --add-architecture i386 && \
    apt-get update

# Thêm repository WineHQ (phương thức mới)
RUN mkdir -p /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    echo "deb [signed-by=/etc/apt/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/ubuntu/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/winehq.list

# Cài đặt các thành phần cần thiết cho Wine
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

# Cấu hình XRDP
RUN echo "xfce4-session" > /etc/skel/.xsession && \
    echo "startxfce4" > /etc/xrdp/startwm.sh && \
    echo "xrandr --output Virtual-1 --mode 1600x900" >> /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh

# Sao chép file entrypoint.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Chạy script khởi động
ENTRYPOINT ["/entrypoint.sh"]
