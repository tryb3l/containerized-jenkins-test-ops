# Containerized Jenkins TestOps

Local containerized continuous integration and telemetry environment for verifying and executing polyglot build pipelines.

## Language

**Controller**:
The central Jenkins coordinator that schedules pipelines, evaluates Configuration as Code, and exposes operational metrics.
_Avoid_: master, server, head node

**Build Agent**:
An ephemeral execution environment provisioned on demand to run pipeline stages for a specific language toolchain.
_Avoid_: slave, worker, runner

**Agent Template**:
A declarative specification that maps a pipeline node label to a Build Agent image, retention policy, and concurrency cap.
_Avoid_: slave definition, node profile

**Socket Proxy**:
The security intermediary that filters container lifecycle requests between the Controller and the host container runtime.
_Avoid_: docker relay, raw socket mount

**Seed Pipeline**:
A pre-loaded pipeline definition used to verify that the Controller can schedule work onto Build Agents across the Socket Proxy.
_Avoid_: test script, dummy job

**Ingress Proxy**:
The HTTP entry point that routes external traffic to the Controller and Observability Dashboard while enforcing route-scoped rate and connection limits.
_Avoid_: load balancer, gateway

**Telemetry Collector**:
The time-series scraper that polls operational metrics from the Controller and stores them for querying.
_Avoid_: monitoring server, stats daemon

**Observability Dashboard**:
The visualization interface provisioned as code to display Controller queue health, Build Agent utilization, and pipeline durations.
_Avoid_: metrics portal, reporting UI

