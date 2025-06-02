#!/bin/bash

set -a
source .env
set +a

PROFILES=""

if [ "$USE_POSTGRES" = "true" ]; then
  PROFILES="$PROFILES --profile postgres"
fi

if [ "$USE_MARIADB" = "true" ]; then
  PROFILES="$PROFILES --profile mariadb"
fi

if [ "$USE_REDIS" = "true" ]; then
  PROFILES="$PROFILES --profile redis"
fi

docker compose $PROFILES down "$@"
