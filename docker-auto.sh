#!/usr/bin/env bash

set -e

SCRIPT_BASE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd "$SCRIPT_BASE_PATH"

###############################################
# Extract Environment Variables from .env file
# Ex. REGISTRY_URL="$(getenv REGISTRY_URL)"
###############################################
getenv(){
    local _env="$(printenv $1)"
    echo "${_env:-$(cat .env | awk 'BEGIN { FS="="; } /^'$1'/ {sub(/\r/,"",$2); print $2;}')}"
}

DOCKER_COMPOSE_VERSION="1.29.2"
CONF_ARG="-f docker-compose-nginx-ssl.yml"
SCRIPT_BASE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
REGISTRY_URL="$(getenv REGISTRY_URL)"

########################################
# Install docker-compose
# DOCKER_COMPOSE_VERSION need to be set
########################################
install_docker_compose() {
    sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    return 0
}

if ! command -v docker-compose >/dev/null 2>&1; then
    install_docker_compose
elif [[ "$(docker-compose version --short)" != "$DOCKER_COMPOSE_VERSION" ]]; then
    install_docker_compose
fi

usage() {
echo "Usage:  $(basename "$0") [MODE] [OPTIONS] [COMMAND]"
echo 
echo "Mode:"
echo "  --ssl-nginx    (default) Encrypted connection and basic auth with Nginx"
echo "  --ssl          Standalone with encrypted connection and basic auth"
echo "  --basic-auth   Only basic authentication without encryption"
echo "  --dev          Development mode no encryption and no basic auth"
echo
echo "Options:"
echo "  --help         Show this help message"
echo
echo "Commands:"
echo "  up             Start the services"
echo "  down            Stop the services"
echo "  ps              Show the status of the services"
echo "  logs            Follow the logs on console"
echo "  clean           Remove deleted images from the filesystem"
echo "  remove-all      Remove all containers"
echo "  stop-all        Stop all containers running"
echo "  create-user     Create a user-password pair to use inside the password file"
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

for i in "$@"
do
case $i in
    --ssl-nginx)
        CONF_ARG="-f docker-compose-nginx-ssl.yml"
        shift
        ;;
    --ssl)
        CONF_ARG="-f docker-compose-ssl.yml"
        shift
        ;;
    --basic-auth)
        CONF_ARG="-f docker-compose-basic-auth.yml"
        shift
        ;;
    --dev)
        CONF_ARG="-f docker-compose-dev.yml"
        shift
        ;;
    --help|-h)
        usage
        exit 1
        ;;
    *)
        break
        ;;
esac
done

echo "Arguments: $CONF_ARG"
echo "Command: $@"

if [ "$1" == "up" ]; then
    docker-compose $CONF_ARG pull
    docker-compose $CONF_ARG build --pull
    docker-compose $CONF_ARG up -d --remove-orphans
    exit 0

elif [ "$1" == "stop-all" ]; then
    if [ -n "$(docker ps --format {{.ID}})" ]
    then docker stop $(docker ps --format {{.ID}}); fi
    exit 0

elif [ "$1" == "remove-all" ]; then
    if [ -n "$(docker ps -a --format {{.ID}})" ]
    then docker rm $(docker ps -a --format {{.ID}}); fi
    exit 0

elif [ "$1" == "logs" ]; then
    shift
    docker-compose $CONF_ARG logs -f --tail 200 "$@"
    exit 0

elif [ "$1" == "clean" ]; then
    docker-compose $CONF_ARG exec registry registry garbage-collect /etc/docker/registry/config.yml
    exit 0

elif [ "$1" == "create-user" ]; then
    if [ $# -lt 3 ]; then
        echo "Usage:  $(basename "$0") create-user [USER] [PASSWORD]"
        exit 1
    fi
    shift
    export BASIC_USER=$1
    export BASIC_PASSWORD=$2
    docker-compose -f docker-compose-htpasswd.yml run htpasswd
    exit 0
fi

docker-compose $CONF_ARG "$@"
