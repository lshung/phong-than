# Sử dụng Ubuntu mới nhất làm base image
FROM ubuntu:latest

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

# Cấu hình tự động chấp nhận EULA cho MS Core Fonts
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections

# Cài đặt Wine và các thành phần cần thiết
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

# Cấu hình XRDP và tối ưu hiệu suất
RUN echo "xfce4-session" > /etc/skel/.xsession && \
    echo "startxfce4" > /etc/xrdp/startwm.sh && \
    echo "xrandr --output Virtual-1 --mode 1600x900" >> /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh && \
    # Tối ưu XRDP
    sed -i 's/max_bpp=32/max_bpp=16/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/crypt_level=high/crypt_level=low/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/g' /etc/xrdp/xrdp.ini && \
    # Tắt các dịch vụ không cần thiết
    systemctl disable cups && \
    systemctl disable avahi-daemon && \
    # Tối ưu hệ thống
    echo "vm.swappiness=10" >> /etc/sysctl.conf && \
    echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf && \
    # Tắt journald
    sed -i 's/#Storage=auto/Storage=none/g' /etc/systemd/journald.conf

# Mount current directory to /app
VOLUME ["/app"]

# Chạy script khởi động
ENTRYPOINT ["/app/entrypoint.sh"]
