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
3. Chạy lệnh:
```bash
bash setup.sh
```

## Kết nối
1. Nếu chưa cài đặt Remmina thì chạy lệnh sau (Fedora):
```bash
sudo dnf install remmina remmina-plugins-rdp
```
2. Kết nối thông qua Remmina RDP:
    - Server: localhost:${RDP_PORT} hoặc {IP}:${RDP_PORT}
    - Username: ${USERNAME}
    - Password: ${PASSWORD}

## Gỡ cài đặt
Để gỡ cài đặt, chạy lệnh:
```bash
bash uninstall.sh
```
