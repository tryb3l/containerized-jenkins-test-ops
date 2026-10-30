# Ephemeral Jenkins Lab

Local Docker Compose environment for running Jenkins pipelines on ephemeral Alpine Build Agents with NGINX HTTPS termination, Prometheus metrics, and a pre-provisioned Grafana dashboard.

## Stack

| Module                                              | Image / Base                               | Purpose                                                                                                                                        |
| :-------------------------------------------------- | :----------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------- |
| **Ingress Proxy** (`nginx`)                         | `alpine:3.21` + NGINX                      | Terminates TLS on `:443`, redirects `:80` → HTTPS, rate-limits `/login` and webhooks (`429`), routes `/` to Jenkins and `/grafana/` to Grafana |
| **Controller** (`controller`)                       | `jenkins/jenkins:lts-alpine-jdk25`         | Zero-executor controller configured via JCasC (`casc.yaml`) and `jenkins-plugin-cli`                                                           |
| **Node.js Build Agent** (`agent-node`)              | `platformatic/node-caged:26-alpine`        | Ephemeral Node.js 26 LTS agent with V8 pointer compression (~50% lower heap), OpenJDK 25 JRE, and `docker-cli`                                 |
| **C# / .NET Build Agent** (`agent-dotnet`)          | `mcr.microsoft.com/dotnet/sdk:10.0-alpine` | Ephemeral .NET 10.0 SDK agent with OpenJDK 25 JRE and `docker-cli`                                                                             |
| **Socket Proxy** (`proxy`)                          | `tecnativa/docker-socket-proxy:v0.5.0`     | Restricts Docker socket API on `tcp://proxy1:2375` (blocks privileged containers, host volumes, and Swarm/system mutations)                    |
| **Telemetry & Dashboard** (`prometheus`, `grafana`) | `prom/prometheus:v3` + slim Alpine Grafana | Scrapes `/prometheus/` every 10s and provisions the `jenkins-testops` dashboard (`GOMEMLIMIT=96MiB`)                                           |

Both Build Agents attach to `jenkins_jenkins-net` with `DOCKER_HOST=tcp://proxy1:2375` so pipelines and **Testcontainers** can launch ephemeral database sidecars (such as `postgres:18-alpine` or `mongo:7`) on demand.

## Prerequisites

- Docker and Docker Compose v2 (`docker compose`)
- `mkcert` _(optional — automatically generates browser-trusted local HTTPS certificates; falls back to `openssl` self-signed certificates)_

## Quick Start

```sh
git clone https://github.com/tryb3l/containerized-jenkins-test-ops.git
cd containerized-jenkins-test-ops

make build
make run
make verify
```

### Endpoints & Default Credentials

- **Jenkins Controller:** `https://localhost/` (HTTP `:80` redirects to HTTPS)
- **Grafana Dashboard:** `https://localhost/grafana/d/jenkins-testops`
- **Prometheus Targets:** `http://127.0.0.1:9090/targets`
- **Default login (Jenkins & Grafana):** `admin` / `admin` _(override via `JENKINS_ADMIN_ID` and `JENKINS_ADMIN_PASSWORD`)_

## Make Targets

| Command             | Action                                                                                                                                                                 |
| :------------------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `make certs`        | Generates `localhost` TLS certificates in `jenkins-nginx/certs/` via `mkcert` (or `openssl` fallback)                                                                  |
| `make build`        | Generates certificates and builds the Controller, Ingress Proxy, Socket Proxy, slim Grafana, and Build Agent images                                                    |
| `make run`          | Builds any missing agent images and starts the stack in detached mode with healthcheck ordering                                                                        |
| `make verify`       | Verifies HTTPS routing, anonymous lock (`403`), form login, `/login` rate limiting (`429`), Prometheus scraping, Grafana provisioning, and the `BasicEnvTest` pipeline |
| `make ps`           | Lists running containers and health statuses                                                                                                                           |
| `make jenkins-log`  | Follows the Jenkins Controller logs                                                                                                                                    |
| `make stop`         | Stops and removes containers                                                                                                                                           |
| `make clean-data`   | Stops containers and removes volumes and networks                                                                                                                      |
| `make clean-images` | Prunes dangling Docker images                                                                                                                                          |

## Repository Layout

```text
├── docker-compose.yml          # Compose v2 topology, healthchecks, and localhost-bound debug ports
├── makefile                    # Build, lifecycle, and verification targets
├── GLOSSARY.md                 # Canonical domain terms
├── docs/adr/                   # Architectural Decision Records
├── jenkins-master/             # Controller Dockerfile, casc.yaml, plugins.txt, and BasicEnvTest seed job
├── jenkins-agent-node/         # Ephemeral Node.js 26 LTS (node-caged) Build Agent Dockerfile
├── jenkins-agent-dotnet/       # Ephemeral C# / .NET 10.0 SDK Build Agent Dockerfile
├── jenkins-nginx/              # NGINX Ingress Proxy Dockerfile, nginx.conf, and jenkins.conf
├── observability/              # Prometheus config, slim Grafana Dockerfile, and provisioned dashboards
├── proxy/                      # Restricted Docker Socket Proxy Dockerfile
└── scripts/                    # setup-agent.sh, generate-certs.sh, and verify.sh
```

## License

MIT
