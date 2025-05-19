#!/bin/bash

# Tạo người dùng nếu chưa tồn tại
if ! id -u $USERNAME > /dev/null 2>&1; then
    useradd -m -G sudo -s /bin/bash $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

    # Khởi tạo Wine (chỉ chạy lần đầu)
    sudo -u $USERNAME env WINEPREFIX=/home/$USERNAME/.wine WINEARCH=win32 wine wineboot --init && \
    sudo -u $USERNAME winetricks -q corefonts
fi

PT_DIR=/home/"$USERNAME"/PhongThan
mkdir -p "$PT_DIR"
chown -R "$USERNAME:$USERNAME" "$PT_DIR"
cd "$PT_DIR"
# Cài đặt wine-mono
if [ ! -f wine-mono-8.1.0-x86.msi ]; then
    sudo -u $USERNAME wget https://dl.winehq.org/wine/wine-mono/8.1.0/wine-mono-8.1.0-x86.msi
    sudo -u $USERNAME wine msiexec -i wine-mono-8.1.0-x86.msi
fi
# Cài đặt wine-gecko
if [ ! -f wine-gecko-2.47.4-x86.msi ]; then
    sudo -u $USERNAME wget https://dl.winehq.org/wine/wine-gecko/2.47.4/wine-gecko-2.47.4-x86.msi
    sudo -u $USERNAME wine msiexec -i wine-gecko-2.47.4-x86.msi
fi
# Tải xuống autoupdate.zip
if [ ! -f autoupdate.zip ]; then
    sudo -u $USERNAME wget http://download.zing.vcdn.vn/download/fs3/fs3new/autoupdate.zip
    sudo -u $USERNAME unzip autoupdate.zip
fi

# Dọn dẹp các phiên XRDP trước đó
rm -rf /tmp/.X11-unix/* /tmp/.X*-lock

# Khởi động các dịch vụ
service dbus start
service xrdp restart

# Giữ container luôn chạy
tail -f /dev/null
