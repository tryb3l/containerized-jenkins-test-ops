# Containerized Jenkins Test Ops

This project provides a containerized Jenkins setup for test operations. It is composed of Docker images for a Jenkins master, a Jenkins agent image, an NGINX reverse proxy, and a lightweight Docker socket proxy. The runtime stack is orchestrated with Docker Compose and helper `make` targets. To keep resource usage low, each image is based on [Alpine Linux](https://alpinelinux.org/).

## Table of Contents

- Prerequisites
- Installation
- Usage
- Project Shape
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

## Project Shape

The current repository is organized around four container roles:

- `master`: the primary Jenkins controller, exposed on ports `8080` and `50000`
- `nginx`: a reverse proxy that exposes port `80` and forwards web traffic to Jenkins
- `slave`: a Jenkins agent image that can be built and reused for worker nodes
- `proxy`: a `socat`-based Docker socket bridge that exposes Docker on TCP port `2375`

At runtime, `docker-compose.yml` wires the `master`, `nginx`, and `proxy` services onto the shared `jenkins-net` network and persists Jenkins state with the `jenkins-data` and `jenkins-log` volumes.

## Folder Structure

- `docker-compose.yml`: defines the service topology, exposed ports, network, and named volumes.
- `makefile`: wraps the main Docker Compose workflows for build, run, stop, cleanup, and log inspection.
- `jenkins-master/`: Jenkins controller image and bootstrap assets.
  - `Dockerfile`: builds the Jenkins master image on Alpine with OpenJDK 21 and supporting tools.
  - `initagent.groovy`: sets the JNLP agent port from environment on startup.
  - `jenkins.sh`: starts Jenkins under `tini`.
  - `jobs/`: seeded Jenkins job definitions.
- `jenkins-slave/`: Jenkins agent image definition.
  - `Dockerfile`: installs the agent runtime dependencies.
  - `files/resolv.conf`: DNS resolver configuration copied into the image.
- `jenkins-nginx/`: reverse proxy image and NGINX configuration.
  - `Dockerfile`: builds the NGINX container.
  - `conf/nginx.conf`: global NGINX configuration.
  - `conf/jenkins.conf`: site configuration that proxies traffic to Jenkins.
- `proxy/`: Docker socket proxy image.
  - `Dockerfile`: starts `socat` to bridge `/var/run/docker.sock` to TCP port `2375`.
- `README.md`: project documentation and operational overview.

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
