# Use Ephemeral Per-Toolchain Build Agents and Platformatic `node-caged`

Instead of installing Node.js, Python, and Java directly on the Jenkins Controller or maintaining a single monolithic agent image, we isolate build toolchains behind the Build Agent seam into two ephemeral Docker-spawned adapters: `jenkins-agent-node` and `jenkins-agent-dotnet`.

For `jenkins-agent-node`, we use `platformatic/node-caged:26-alpine` rather than the standard `node:26-alpine` distribution. `node-caged` builds Node.js with V8 pointer compression enabled, cutting V8 heap memory usage by roughly 50% and improving CPU cache locality at the trade-off of a 4 GB maximum heap per V8 isolate—a trade-off well suited to parallel containerized CI test runs capped by `containerCap: 4`.
