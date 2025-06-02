#!/bin/bash

set -a
source .env
set +a

ACTION="$1"
shift

PROFILES=""

[ "$USE_POSTGRES" = "true" ] && PROFILES="$PROFILES --profile postgres"
[ "$USE_MARIADB" = "true" ] && PROFILES="$PROFILES --profile mariadb"
[ "$USE_REDIS" = "true" ] && PROFILES="$PROFILES --profile redis"

case "$ACTION" in
  up)
    docker compose $PROFILES up -d "$@"
    ;;
  down)
    docker compose $PROFILES down "$@"
    ;;
  *)
    echo "Usage: $0 {up|down} [additional docker-compose args]"
    exit 1
    ;;
esac
