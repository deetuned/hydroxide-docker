#!/bin/bash

# Load use-case specific, secret variables into the session
set -a && eval "$(<./.env.private)" && set +a
# Generate the compose environment file and ingest the variables
cat ./.env.tpl | envsubst > .env
set -a && eval "$(<./.env)" && set +a

# initialise the directory with private permissions
mkdir -p /data/hydroxide
chown 1000 /data/hydroxide
chgrp 1000 /data/hydroxide
chmod g+rwxs /data/hydroxide
chmod o-rwx /data/hydroxide
