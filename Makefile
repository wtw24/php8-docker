init: docker-down pre-scripts docker-pull docker-build docker-up app-init success info
clear-init: docker-down-clear pre-scripts docker-pull docker-build docker-up app-init success info
up: docker-up success info
down: docker-down
restart: down up

pre-scripts: create-networks create-env-file create-bash-history-file

docker-up:
	docker compose up -d

docker-down:
	docker compose down --remove-orphans

docker-down-clear:
	docker compose down -v --remove-orphans

docker-pull:
	docker compose pull

docker-build:
	docker compose build --pull

create-networks:
	@docker network create proxy proxy 2>/dev/null || true
	@docker network create develop proxy 2>/dev/null || true

create-env-file:
	@docker run --rm -it -v ${PWD}/:/app -u $(shell id -u):$(shell id -g) -w /app bash:5.2 bash docker/bin/create-env-file.sh

create-bash-history-file:
	@docker run --rm -v ${PWD}/:/app -u $(shell id -u):$(shell id -g) -w /app bash:5.2 bash docker/bin/create-bash_history.sh

php:
	docker compose run --rm php-cli bash

node:
	docker compose run --rm node bash

app-init: composer-install

composer-install:
	docker compose run --rm php-cli composer install --no-progress

success:
	@echo "\033[32m "
	@echo "Docker Compose Stack successfully started!"
	@echo "\033[0m"

info:
	@echo "STACK URLS:"
	@echo " - App: \t https://app.localhost"
	@echo ""