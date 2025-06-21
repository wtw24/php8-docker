# PHP 8 Docker Development Environment

This repository provides a comprehensive Docker-based development environment for PHP 8 applications. It includes pre-configured services for Nginx, PHP-FPM, PHP-CLI (with Composer, Symfony CLI, Laravel Installer), Node.js, and optional databases (MariaDB, PostgreSQL) and caching (Redis).

## Development Environment Links

After starting the environment, your application will typically be accessible at:
- http://app.loc
- https://app.loc

Buggregator (if enabled and running) will be accessible at:
- http://127.0.0.1:8000

## Prerequisites

- Docker and Docker Compose
- `mkcert` (for generating local SSL certificates)

## Initial Setup

### 1. Add Subdomain to Hosts File

You need to add `app.loc` to your system's `hosts` file to point to your local machine.
Open `/etc/hosts` (on Linux/macOS) or `C:\Windows\System32\drivers\etc\hosts` (on Windows) with administrator privileges and add the following line:

```shell
127.0.0.1 app.loc
```

### 2. HTTPS (SSL) on localhost with `mkcert`

This environment uses `mkcert` to generate trusted SSL certificates for local development.

**Install `mkcert`:**
- If you don't have `mkcert` installed, follow the instructions here: https://github.com/FiloSottile/mkcert
- For Debian/Ubuntu, you can install it using:
  ```shell
  sudo apt install libnss3-tools mkcert
  ```

**Create a new local Certificate Authority (CA):**
- This step is only required once on the machine (host) where you will be accessing the site in a browser (e.g., your main development machine). It installs the local CA into the system and browser trust stores.
  ```shell
  mkcert -install
  ```

**Generate certificates for the project:**
- Navigate to the root directory of this project and run:
  ```shell
  make certs
  ```
  This will generate `local-cert.pem` and `local-key.pem` for `app.loc` (used by Nginx) and `localhost` (can be used by Node/Vite) in the `docker/development/nginx/certs` and `docker/development/node/certs` directories respectively.

## Environment Management

This project uses a `Makefile` for easy environment management.

### Initialize and Start Environment (First time or full rebuild)

This command will pull the latest base images, build your project's images, create necessary initial files, and start all services. It will also run `composer install` for your project in `src/`.

```shell
make init
```

### Start Environment (After initial setup)

If the environment has already been set up and you just need to start the services:

```shell
make up
```

### Stop Environment

This command stops and removes the Docker containers:

```shell
make down
```
To also remove Docker volumes (e.g., database data), use `make docker-down-clear` (or `make clear-init` for a full reset) if you need a completely clean start.

### Restart Environment

```shell
make restart
```

## Running Bash in Containers

### PHP-CLI Container

To execute PHP scripts, Composer commands, Symfony CLI, or Laravel Artisan commands, you can open a bash session in the `php-cli` container:

```shell
make php
```
You will be placed in the `/app` directory, which is your local `./src` directory.

### Node Container

For Node.js related tasks (e.g., npm/yarn commands, running Vite):

```shell
make node
```
To start the Vite development server (which runs `npm run dev`):
```shell
make vite
```

## Project Setup Examples

The `php-cli` container comes with Composer, Symfony CLI, and Laravel Installer pre-installed. You can use these tools to set up new projects within the `src/` directory.

**Important:** The following examples assume you are starting with an empty or clean `src/` directory. The `rm -rf *` command is shown to demonstrate clearing the directory *inside the container*. Use with caution.

### Setting up a New Symfony Project

1.  **Ensure certificates are generated and the environment is running:**
    ```shell
    make certs
    make init
    ```

2.  **Enter the PHP-CLI container:**
    ```shell
    make php
    ```

3.  **Inside the container (working directory `/app`, which maps to `./src`):**
    ```bash
    # Optional: If your src/ directory is not empty and you want a fresh start
    # rm -rf *

    # Create a new Symfony project in the current directory (/app)
    symfony new . --no-git

    # You can also check Symfony requirements
    # symfony check:requirements

    # Exit the container
    # exit
    ```
    Your new Symfony project will be in the `./src` directory on your host machine.

### Setting up a New Laravel Project

1.  **Ensure certificates are generated and the environment is running:**
    ```shell
    make certs
    make init
    ```

2.  **Enter the PHP-CLI container:**
    ```shell
    make php
    ```

3.  **Inside the container (working directory `/app`, which maps to `./src`):**
    ```bash
    # Optional: If your src/ directory is not empty and you want a fresh start
    # rm -rf *

    # Create a new Laravel project in the current directory (/app)
    composer create-project --prefer-dist laravel/laravel .

    # Exit the container
    # exit
    ```
    Your new Laravel project will be in the `./src` directory on your host machine. Remember to configure Laravel's `.env` file, especially database connections if you plan to use the MariaDB or PostgreSQL services.

## Available Services (via `compose.yml`)

-   **`nginx`**: Web server serving your application from `src/public`.
-   **`php-fpm`**: PHP FastCGI Process Manager to execute PHP code for Nginx.
-   **`php-cli`**: PHP command-line interface with Composer, Symfony CLI, Laravel Installer, and Xdebug (if enabled via `.env`).
-   **`node`**: Node.js environment for frontend tasks. Includes npm.
-   **`mariadb`** MariaDB service. Activated by USE_MARIADB=true in `.env`. Defined with profile mariadb in compose.yml.
-   **`postgres`** PostgreSQL service. Activated by USE_POSTGRES=true in `.env`. Defined with profile postgres in compose.yml.
-   **`redis`**  Redis in-memory data store. Activated by USE_REDIS=true in `.env`. Defined with profile redis in compose.yml.
-   **`buggregator`** Debugging tool. Activated by USE_BUGGREGATOR=true in `.env`. Defined with profile buggregator in compose.yml.

Scripts used by Makefile (e.g., docker-compose.sh) read USE_... variables from your `.env` file and enable service profiles accordingly when running docker compose.

## Key Features

-   Configurable PHP version and Xdebug installation via `.env`.
-   Support for common PHP extensions.
-   Persistent data storage for databases and Redis using Docker volumes.
-   Symfony CLI and Laravel Installer available out-of-the-box in `php-cli`.
-   Easy SSL setup for `https://app.loc`.
-   Flexible service management via environment variables in `.env`.
