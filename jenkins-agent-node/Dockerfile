ARG NODE_IMAGE=platformatic/node-caged:26-alpine
FROM ${NODE_IMAGE}

COPY scripts/setup-agent.sh /tmp/setup-agent.sh
RUN sh /tmp/setup-agent.sh && rm -f /tmp/setup-agent.sh

USER jenkins
WORKDIR /home/jenkins
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["sh", "-c", "trap 'exit 0' TERM INT; while :; do sleep 1; done"]

