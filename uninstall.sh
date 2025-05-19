#!/bin/bash

# Load các biến môi trường
source .env

# Xóa container
docker stop ${CONTAINER_NAME}
docker rm ${CONTAINER_NAME}

# Xóa image
docker rmi ${IMAGE_NAME}
