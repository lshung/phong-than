#!/bin/bash

DESKTOP_DIR="/home/$USERNAME/Desktop"
PT_DIR=/home/"$USERNAME"/PhongThan

# Tạo người dùng nếu chưa tồn tại
if ! id -u $USERNAME > /dev/null 2>&1; then
    useradd -m -G sudo -s /bin/bash $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

    # Khởi tạo Wine (chỉ chạy lần đầu)
    sudo -u $USERNAME env WINEPREFIX=/home/$USERNAME/.wine WINEARCH=win32 wine wineboot --init && \
    sudo -u $USERNAME winetricks -q corefonts
fi

# Tạo các thư mục
mkdir -p "$DESKTOP_DIR"
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

# Shortcut cho thư mục PhongThan
cat > "$DESKTOP_DIR/PhongThan.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=PhongThan
Comment=PhongThan Directory
Exec=thunar "$PT_DIR"
Icon=folder
EOF

# Shortcut cho autoupdate.exe
cat > "$DESKTOP_DIR/AutoUpdate.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=AutoUpdate
Comment=PhongThan AutoUpdate
Exec=wine "$PT_DIR/autoupdate.exe"
Icon=wine
Terminal=false
Path=$PT_DIR
EOF

# Shortcut cho game.exe
cat > "$DESKTOP_DIR/Game.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Game
Comment=PhongThan Game
Exec=wine "$PT_DIR/game.exe"
Icon=wine
Terminal=false
Path=$PT_DIR
EOF

# Cấp quyền cho các shortcut
chown -R "$USERNAME:$USERNAME" "$DESKTOP_DIR"
chmod +x "$DESKTOP_DIR"/*.desktop

# Thêm Wine vào danh sách ứng dụng mặc định (system-wide)
cat > /usr/share/applications/wine.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Wine
Comment=Run Windows Applications
Exec=wine %f
Icon=wine
Terminal=false
Categories=Utility;Emulator;
MimeType=application/x-ms-dos-executable;application/x-msi;application/x-ms-shortcut;
EOF

# Thêm Wine vào danh sách ứng dụng của người dùng
mkdir -p /home/$USERNAME/.local/share/applications
cat > /home/$USERNAME/.local/share/applications/wine.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Wine
Comment=Run Windows Applications
Exec=wine %f
Icon=wine
Terminal=false
Categories=Utility;Emulator;
MimeType=application/x-ms-dos-executable;application/x-msi;application/x-ms-shortcut;
EOF

# Cấp quyền cho file cấu hình
chmod +x /usr/share/applications/wine.desktop
chmod +x /home/$USERNAME/.local/share/applications/wine.desktop
chown -R "$USERNAME:$USERNAME" /home/$USERNAME/.local

# Dọn dẹp các phiên XRDP trước đó
rm -rf /tmp/.X11-unix/* /tmp/.X*-lock

# Khởi động các dịch vụ
service dbus start
service xrdp restart

# Giữ container luôn chạy
tail -f /dev/null
