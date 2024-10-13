# Containerized Jenkins Test Ops

This project sets up a Jenkins environment using Docker containers. It includes a Jenkins master, Jenkins slave, NGINX as a reverse proxy, and a proxy service. The environment is designed to simplify the process of setting up and managing Jenkins for testing operations. The Jenkins master is pre-configured with plugins and jobs for testing environments. The NGINX proxy is used to route requests to the Jenkins master and slave nodes. The proxy service is used to manage the NGINX configuration and reload the configuration when changes are made. The project includes a Makefile with targets for building, running, and stopping the Docker containers. The project is intended to be used as a starting point for setting up a Jenkins environment for testing operations. Each project use case is different, so you may need to customize the configuration to fit your needs. In order to decrease resourse usage, each container is built with a minimalistic image, based on [Alpine Linux](https://alpinelinux.org/).

## Table of Contents

- Prerequisites
- Installation
- Usage
- Folder Structure
- Makefile Targets
- Additional Information
- Contributing
- License

## Prerequisites

- Docker installed on your system
- Docker Compose installed

## Installation

Clone the repository:

```sh
git clone https://github.com/yourusername/containerized-jenkins-test-ops.git
cd containerized-jenkins-test-ops
```

## Usage

To build and run the Docker containers, use the following commands:

```sh
make build
make run
```

To stop the containers:

```sh
make stop
```

To clean up the containers and remove volumes:

```sh
make clean-data
make clean-images
```

## Folder Structure

- `jenkins-master/`: Contains the Dockerfile and configuration files for the Jenkins master node.

  - `Dockerfile`: Builds the Jenkins master image with required plugins.
  - `initagent.groovy`: Groovy script to initialize Jenkins agents.
  - `jenkins.sh`: Startup script for the Jenkins master.
  - `plugins.txt`: List of Jenkins plugins to install.
  - `jobs/`: Contains Jenkins job configurations.
    - `BasicEnvTest/config.xml`: Configuration for the "BasicEnvTest" job.

- `jenkins-slave/`: Contains the Dockerfile and files for the Jenkins slave node.

  - `Dockerfile`: Builds the Jenkins slave image.
  - `files/`: Additional files needed for the slave.
    - `resolv.conf`: DNS resolver configuration.

- `jenkins-nginx/`: Contains the Dockerfile and NGINX configuration files.

  - `Dockerfile`: Builds the NGINX image for proxying requests to Jenkins.
  - `conf/`: NGINX configuration directory.
    - `nginx.conf`: Main NGINX configuration.
    - `jenkins.conf`: NGINX site configuration for Jenkins.

- `proxy/`: Contains the Dockerfile and configurations for the proxy service.

  - `Dockerfile`: Builds the proxy image.

- `docker-compose.yml`: Defines services, networks, and volumes for Docker Compose.
-

makefile

## : Contains make targets for managing the Docker environment.

README.md

: Project documentation.

## Makefile Targets

- `make build`: Builds the Docker images using Docker Compose.
- `make run`: Runs the Jenkins master, NGINX, and proxy containers in detached mode.
- `make stop`: Stops and removes the containers.
- `make clean-data`: Stops containers and removes containers, networks, volumes, and images created by [up].
- `make clean-images`: Removes dangling Docker images to free up space.
- `make ps`: Lists containers managed by Docker Compose.
- `make jenkins-log`: Tails the Jenkins master log for debugging.

## License

This project is licensed under the MIT License.
