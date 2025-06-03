# PHP 8 Docker Development Environment


## Links for Development Environment
- http://app.loc
- https://app.loc


## Add subdomains to host /etc/hosts
~~~shell
127.0.0.1 app.loc
~~~

# HTTPS (SSL) on localhost
- https://github.com/FiloSottile/mkcert

## Install on Ubuntu `mkcert`
~~~shell
sudo apt install libnss3-tools mkcert
~~~

## Create a new local CA
~~~shell
mkcert -install
~~~

## Generate certificate for domain `app.loc` and their subdomains
~~~shell
cd docker/development/nginx/certs \
  && mkcert -cert-file local-cert.pem -key-file local-key.pem "app.loc" "*.app.loc" \
  && cd -
cd docker/development/node/certs \
  && mkcert -cert-file local-cert.pem -key-file local-key.pem "localhost" \
  && cd -
~~~
or
~~~shell
make certs
~~~


## Environment Start/Restart
~~~shell
make init
~~~

## Environment Start
~~~shell
make up
~~~

## Environment Stop
~~~shell
make down
~~~


# Run Bash

## Run Bash from php-cli container
~~~shell
make php
~~~

## Run Bash from node-cli container
~~~shell
make node
~~~