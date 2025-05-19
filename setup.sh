#!/bin/bash

# Load các biến môi trường
source .env

# Build image
docker build -t ${IMAGE_NAME} .

# Khởi chạy container
docker run -d \
    --name ${CONTAINER_NAME} \
    -p ${RDP_PORT}:3389 \
    --env-file .env \
    --dns 8.8.8.8 \
    ${IMAGE_NAME}
