Cài đặt game Phong Thần trên Linux sử dụng Docker, Wine và XRDP.

Phù hợp để cắm máy, không phù hợp để chơi trực tiếp.

## Cài đặt

1. Tạo file `.env` chứa các biến môi trường:
```bash
cp env.sample .env && chmod 600 .env
```

2. Chỉnh sửa các biến môi trường trong file `.env`:
    - `USERNAME`: Tên đăng nhập RDP (mặc định: **user**)
    - `PASSWORD`: Mật khẩu RDP (mặc định: **password**)
    - `RDP_PORT`: Cổng RDP (mặc định: **3390**)
    - `IMAGE_NAME`: Tên Docker image (mặc định: **pt-img**)
    - `CONTAINER_NAME`: Tên Docker container (mặc định: **pt-ctn**)
    - `MAX_RAM`: Dung lượng RAM tối đa (mặc định: **4g**)
    - `MAX_CPU`: Số lượng CPU tối đa (mặc định: **2**)
    - `SHM_SIZE`: Shared memory size (mặc định: **256m**)

3. Chạy lệnh sau và chọn menu **Cài đặt container**:
```bash
bash main.sh
```

## Kết nối

1. Có thể kết nối từ Linux hoặc Windows:
    - Windows: sử dụng Remote Desktop Connection
    - Linux: sử dụng Remmina

2. Thông số kết nối:
    - Server: localhost:${RDP_PORT} hoặc {IP}:${RDP_PORT}
    - Username: ${USERNAME}
    - Password: ${PASSWORD}

3. Nếu chưa cài đặt Remmina thì chạy lệnh sau (Fedora):
```bash
sudo dnf install remmina remmina-plugins-rdp
```

## Gỡ cài đặt

Chạy lệnh sau và chọn menu **Gỡ cài đặt container**:
```bash
bash main.sh
```
