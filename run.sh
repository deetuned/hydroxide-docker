#!/bin/bash -e

./setup.sh

read -p "Enter ProtonMail 2FA token if enabled. Ensure sufficient duration left on the token: " -N 6 EXTRA_2FA && \
   docker-compose up -d --build && \
   export EXTRA_2FA=""
