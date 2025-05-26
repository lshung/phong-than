#!/bin/bash

# Tạo người dùng nếu chưa tồn tại
if ! id -u $USERNAME > /dev/null 2>&1; then
    useradd -m -s /bin/bash $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd
fi

# Tạo các Desktop shortcut
/app/main.sh --create-shortcuts $USERNAME

# Dọn dẹp các phiên XRDP trước đó
rm -rf /tmp/.X11-unix/* /tmp/.X*-lock

# Khởi động các dịch vụ
service dbus start
service xrdp restart

# Giữ container luôn chạy
tail -f /dev/null
