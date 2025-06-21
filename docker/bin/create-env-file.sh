#!/usr/bin/env bash
set -euo pipefail

set -a
source .env
set +a

R="\e[31m"
G="\e[32m"
Y="\e[33m"
EC="\e[0m"

ENV_FILE=".env"
ENV_FILE_TEMPLATE=".env.example"

confirm() {
    echo -e -n "${Y}${1:-Are you sure?}${EC} [${R}y${EC}/${G}N${EC}] (continuing in 20s) "
    read -t 20 -r -n 1 response || true
    printf "\n"
    if [[ "${response:-}" =~ ^[yY]$ ]]; then
        return 0
    fi
    return 1
}

if [ ! -f "${ENV_FILE}" ]; then
    cp "${ENV_FILE_TEMPLATE}" "${ENV_FILE}"
    echo -e "${Y}.env${EC} file created from ${Y}.env.example${EC}"
else
    if [ "${SKIP_ENV_OVERWRITE_CHECK:-false}" = "true" ]; then
        echo -e "The ${Y}${ENV_FILE}${EC} file already exists. Overwrite check is disabled (SKIP_ENV_OVERWRITE_CHECK=true)."
    else
        if ! cmp -s "${ENV_FILE}" "${ENV_FILE_TEMPLATE}"; then
          if confirm "The contents of '${ENV_FILE}' differ from '${ENV_FILE_TEMPLATE}'. Overwrite '${ENV_FILE}'?"; then
            cp "${ENV_FILE_TEMPLATE}" "${ENV_FILE}"
            echo -e "The ${Y}${ENV_FILE}${EC} file has been updated."
          else
            echo -e "The ${Y}${ENV_FILE}${EC} file was not overwritten by user choice."
          fi
        else
          echo -e "The ${Y}${ENV_FILE}${EC} file already exists and is identical to ${Y}${ENV_FILE_TEMPLATE}${EC}. No action required."
        fi
    fi
fi
