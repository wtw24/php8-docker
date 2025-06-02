init: docker-down pre-scripts docker-pull docker-build docker-up app-init success info
clear-init: docker-down-clear pre-scripts docker-pull docker-build docker-up app-init success info
up: docker-up success info
down: docker-down
restart: down up

pre-scripts: create-env-file create-bash-history-file

docker-up: chmod-compose
	./docker-compose.sh up

docker-down: chmod-compose
	./docker-compose.sh down --remove-orphans

docker-down-clear: chmod-compose
	./docker-compose.sh down -v --remove-orphans

docker-pull:
	docker compose pull

docker-build:
	docker compose build --pull

chmod-compose:
	chmod +x docker-compose.sh

create-env-file:
	@docker run --rm -it -v ${PWD}/:/app -u $(shell id -u):$(shell id -g) -w /app bash:5.2 bash docker/bin/create-env-file.sh

create-bash-history-file:
	@docker run --rm -v ${PWD}/:/app -u $(shell id -u):$(shell id -g) -w /app bash:5.2 bash docker/bin/create-bash_history.sh

php:
	docker compose run --rm php-cli bash

node:
	docker compose run --rm node bash

vite:
	docker compose run --rm --service-ports node bash -c "npm run dev"

app-init: composer-install

composer-install:
	docker compose run --rm php-cli composer install --no-progress

success:
	@echo "\033[32m "
	@echo "Docker Compose Stack successfully started!"
	@echo "\033[0m"

info:
	@echo "STACK URLS:"
	@echo " - App: \t https://app.loc"
	@echo ""

certs:
	cd docker/development/nginx/certs && mkcert -cert-file local-cert.pem -key-file local-key.pem "app.loc" "*.app.loc"
	cd docker/development/node/certs && mkcert -cert-file local-cert.pem -key-file local-key.pem "localhost"

-include src/Makefile