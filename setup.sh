#!/bin/bash

# Build the image
docker build -t pt-img .

# Run the container
docker run -d \
    --name pt-ctn \
    -p 3390:3390 \
    --env-file env \
    pt-img
