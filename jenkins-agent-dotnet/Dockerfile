ARG DOTNET_IMAGE=mcr.microsoft.com/dotnet/sdk:10.0-alpine
FROM ${DOTNET_IMAGE}

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1 \
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

COPY scripts/setup-agent.sh /tmp/setup-agent.sh
RUN sh /tmp/setup-agent.sh && rm -f /tmp/setup-agent.sh

USER jenkins
WORKDIR /home/jenkins
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["sh", "-c", "trap 'exit 0' TERM INT; while :; do sleep 1; done"]

