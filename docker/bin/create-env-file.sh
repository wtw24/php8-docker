#!/usr/bin/env bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
EC="\e[0m"

ENV_FILE=".env"
ENV_FILE_TEMPLATE=".env.example"

confirm() {
    echo -e -n "${Y}${1:-Are yu sure?}${EC} [${R}y${EC}/${G}N${EC}] (continuing in 20s) "
    read -t 20 -r -n 1 response
    printf "\n"
    if [[ "$response" =~ ^[yY]$ ]]; then
        return 0
    fi
    return 1
}

if [ ! -f "${ENV_FILE}" ]; then
    cp ${ENV_FILE_TEMPLATE} ${ENV_FILE}
    echo -e "${Y}.env${EC} file created from ${Y}.env.example${EC}"
else
    if
      [[ 2 -eq $(md5sum "${ENV_FILE}" "${ENV_FILE_TEMPLATE}" | awk '{print $1}' | uniq | wc -l) ]] \
      && confirm "The contents of the '${ENV_FILE}' file are different from the contents of '${ENV_FILE_TEMPLATE}'. Update the '${ENV_FILE}' file?";
    then
        cp ${ENV_FILE_TEMPLATE} ${ENV_FILE}
        echo -e "The ${Y}${ENV_FILE}${EC} file has been updated."
    fi
fi