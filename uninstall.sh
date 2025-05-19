#!/bin/bash

# Xóa container
docker stop pt-ctn
docker rm pt-ctn

# Xóa image
docker rmi pt-img
