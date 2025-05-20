#!/bin/bash

# Kiểm tra và tạo file .env nếu chưa tồn tại
if [ ! -f .env ]; then
    if [ -f env.sample ]; then
        cp env.sample .env
        chmod 600 .env
    else
        echo "Không tìm thấy file env.sample!" 1>&2
        exit 1
    fi
fi

# Load các biến môi trường
source .env

# Hàm cài đặt
__setup() {
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

    # Khởi chạy container
    docker run -d \
        --name ${CONTAINER_NAME} \
        -p ${RDP_PORT}:3389 \
        --env-file .env \
        --dns 8.8.8.8 \
        ${IMAGE_NAME}
}

# Hàm gỡ cài đặt
__uninstall() {
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

# Hàm hiển thị menu
__show_menu() {
    echo "=============== MENU ==============="
    echo "1. Cài đặt"
    echo "2. Gỡ cài đặt"
    echo "3. Cập nhật repo"
    echo "0. Thoát"
    echo "===================================="
}

# Hàm xử lý lựa chọn
__handle_choice() {
    local choice=$1
    case $choice in
        1) __setup ;;
        2) __uninstall ;;
        3) __update_repo ;;
        0|q|quit|exit) echo "Tạm biệt!"; echo; exit 0 ;;
        *) echo "Lựa chọn không hợp lệ!" ;;
    esac
}

# Vòng lặp chính
while true; do
    __show_menu
    read -p "Nhập lựa chọn của bạn: " choice
    __handle_choice $choice
    echo
done
