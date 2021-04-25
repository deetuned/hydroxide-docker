#!/bin/bash

# Note that explicitly building the image is not necessary
#   if using docker-compose
docker build . --build-arg APP_VERSION=${APP_VERSION} --tag "${IMAGE_NAME}:${APP_VERSION}" --tag "${IMAGE_NAME}:latest"
