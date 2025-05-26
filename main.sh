#!/bin/bash

# Lấy đường dẫn thư mục của file hiện hành
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Hàm kiểm tra xem script có đang chạy trong container hay không
__is_in_container() {
    [ -f /.dockerenv ]
}

# Nếu không chạy trong container thì tạo file .env và load các biến môi trường
if ! __is_in_container; then
    # Kiểm tra và tạo file .env nếu chưa tồn tại
    if [ ! -f "${SCRIPT_DIR}/.env" ]; then
        if [ -f "${SCRIPT_DIR}/env.sample" ]; then
            cp "${SCRIPT_DIR}/env.sample" "${SCRIPT_DIR}/.env"
            chmod 600 "${SCRIPT_DIR}/.env"
        else
            echo "Không tìm thấy file env.sample!" 1>&2
            exit 1
        fi
    fi

    # Load các biến môi trường
    source "${SCRIPT_DIR}/.env"
fi

# Hàm cài đặt container
__setup_container() {
    # Kiểm tra image đã tồn tại
    if docker images --format '{{.Repository}}' | grep -q "^${IMAGE_NAME}$"; then
        echo "Image ${IMAGE_NAME} đã tồn tại!" 1>&2
        return 1
    fi

    # Kiểm tra container đã tồn tại
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container ${CONTAINER_NAME} đã tồn tại!" 1>&2
        return 1
    fi

    # Build image
    docker build -t ${IMAGE_NAME} .

    # Khởi chạy container với giới hạn tài nguyên
    docker run -d \
        --name ${CONTAINER_NAME} \
        -p ${RDP_PORT}:3389 \
        --env-file .env \
        --volume $(pwd):/app \
        --dns 8.8.8.8 \
        --memory=${MAX_RAM} \
        --memory-swap=${MAX_RAM} \
        --cpus=${MAX_CPU} \
        --shm-size=${SHM_SIZE} \
        --restart unless-stopped \
        ${IMAGE_NAME}
}

# Hàm gỡ cài đặt container
__remove_container() {
    # Kiểm tra container có tồn tại
    if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container ${CONTAINER_NAME} không tồn tại!" 1>&2
    else
        docker rm -f ${CONTAINER_NAME}
    fi

    # Kiểm tra image có tồn tại
    if ! docker images --format '{{.Repository}}' | grep -q "^${IMAGE_NAME}$"; then
        echo "Image ${IMAGE_NAME} không tồn tại!" 1>&2
    else
        docker rmi ${IMAGE_NAME}
    fi
}

# Hàm cập nhật repository
__update_repo() {
    git pull origin master
}

# Hàm cài đặt game
__install_game() {
    # Lấy tên người dùng hiện tại vì hàm này sẽ chạy trong container
    local username=$(whoami)

    # Thư mục chứa cài đặt game và Wine prefix
    local pt_setup_dir="/home/$username/PhongThan"
    local pt_wine_dir="/home/$username/.pt"

    # Kiểm tra nếu game đã được cài đặt
    if [ -f "$pt_setup_dir/game.exe" ]; then
        read -p "Game Phong Thần đã được cài đặt. Bạn có muốn cài đặt lại không? (y/N): " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            exit 0
        fi
    fi

    # Khởi tạo lại các thư mục
    rm -rf "$pt_wine_dir"
    rm -rf "$pt_setup_dir" && mkdir -p "$pt_setup_dir"

    # Thiết lập Windows 10 32-bit
    WINEPREFIX="$pt_wine_dir" WINEARCH=win32 winetricks -q win10

    # Chuyển đến thư mục cài đặt game
    cd "$pt_setup_dir"

    # Tải xuống và cài đặt wine-gecko
    if [ ! -f wine-gecko-2.47.4-x86.msi ]; then
        wget https://dl.winehq.org/wine/wine-gecko/2.47.4/wine-gecko-2.47.4-x86.msi
    fi
    WINEPREFIX="$pt_wine_dir" wine msiexec -i wine-gecko-2.47.4-x86.msi

    # Tải xuống và giải nén game
    if [ ! -f autoupdate.zip ]; then
        wget http://download.zing.vcdn.vn/download/fs3/fs3new/autoupdate.zip
        unzip autoupdate.zip
    fi

    # Tìm và chạy file AutoUpdate.exe
    local auto_update_exe=$(find "$pt_setup_dir" -type f -name "AutoUpdate*.exe" | head -n 1)
    if [ -n "$auto_update_exe" ]; then
        WINEPREFIX="$pt_wine_dir" wine "$auto_update_exe"
        exit 0
    else
        echo "Lỗi: Không tìm thấy file AutoUpdate.exe" 1>&2
        exit 1
    fi
}

# Hàm tạo shortcut
__create_shortcuts() {
    # Lấy tên người dùng từ tham số
    local username=$1

    # Thư mục Desktop, PhongThan và Wine prefix
    local desktop_dir="/home/$username/Desktop"
    local pt_setup_dir="/home/$username/PhongThan"
    local pt_wine_dir="/home/$username/.pt"

    # Tạo thư mục Desktop và PhongThan
    mkdir -p "$desktop_dir"
    mkdir -p "$pt_setup_dir"

    # Xóa tất cả các shortcut cũ
    rm -rf "$desktop_dir"/*

    # Tạo shortcut cho install.sh
    cat > "$desktop_dir/Install.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Install
Comment=PhongThan Install
Exec=bash /app/main.sh --install-game
Icon=system-software-install
Terminal=true
Path=/app
EOF

    # Tạo shortcut cho autoupdate.exe
    cat > "$desktop_dir/AutoUpdate.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=AutoUpdate
Comment=PhongThan AutoUpdate
Exec=env WINEPREFIX="$pt_wine_dir" wine "$pt_setup_dir/autoupdate.exe"
Icon=wine
Terminal=false
Path=$pt_setup_dir
EOF

    # Tạo shortcut cho game.exe
    cat > "$desktop_dir/Game.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Game
Comment=PhongThan Game
Exec=env WINEPREFIX="$pt_wine_dir" wine "$pt_setup_dir/game.exe"
Icon=wine
Terminal=false
Path=$pt_setup_dir
EOF

    # Cấp quyền cho các shortcut
    chown -R "$username:$username" "$desktop_dir"
    chmod +x "$desktop_dir"/*.desktop
}

# Hàm hiển thị menu
__show_menu() {
    echo "=============== MENU ==============="
    echo "1. Cài đặt container"
    echo "2. Gỡ cài đặt container"
    echo "3. Cập nhật repo"
    echo "0. Thoát"
    echo "===================================="
}

# Hàm xử lý lựa chọn
__handle_choice() {
    local choice=$1
    case $choice in
        1) __setup_container ;;
        2) __remove_container ;;
        3) __update_repo ;;
        0|q|quit|exit) echo "Tạm biệt!"; echo; exit 0 ;;
        *) echo "Lựa chọn không hợp lệ!" ;;
    esac
}

# Xử lý tham số dòng lệnh
if [ "$1" = "--setup-container" ]; then
    __setup_container
elif [ "$1" = "--remove-container" ]; then
    __remove_container
elif [ "$1" = "--update-repo" ]; then
    __update_repo
elif [ "$1" = "--install-game" ]; then
    __install_game
elif [ "$1" = "--create-shortcuts" ]; then
    __create_shortcuts "$2"
# Nếu không có tham số thì hiển thị menu
else
    while true; do
        __show_menu
        read -p "Nhập lựa chọn của bạn: " choice
        __handle_choice $choice
        echo
    done
fi
