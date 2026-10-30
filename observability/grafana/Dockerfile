FROM grafana/grafana-oss:13.0.2 AS upstream

USER root
RUN apk add --no-cache binutils && \
    strip -s /usr/share/grafana/bin/grafana && \
    rm -rf /usr/share/grafana/data/plugins-bundled \
           /usr/share/grafana/public/test \
           /usr/share/grafana/public/openapi3.json \
           /usr/share/grafana/public/api-merged.json \
           /usr/share/grafana/public/api-enterprise-spec.json && \
    find /usr/share/grafana/public -type f \( -name "*.map" -o -name "*.ts" -o -name "*.tsx" -o -name "*.md" -o -name "*.snap" \) -delete

FROM alpine:3.21

ENV PATH="/usr/share/grafana/bin:$PATH" \
    GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/var/lib/grafana" \
    GF_PATHS_HOME="/usr/share/grafana" \
    GF_PATHS_LOGS="/var/log/grafana" \
    GF_PATHS_PLUGINS="/var/lib/grafana/plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning" \
    GF_PLUGINS_PREINSTALL="" \
    GF_PLUGINS_PREINSTALL_DISABLED="true" \
    GF_UNIFIED_ALERTING_ENABLED="false" \
    GF_ALERTING_ENABLED="false" \
    GF_ANALYTICS_REPORTING_ENABLED="false" \
    GF_ANALYTICS_CHECK_FOR_UPDATES="false" \
    GF_ANALYTICS_CHECK_FOR_PLUGIN_UPDATES="false" \
    GF_NEWS_NEWS_FEED_ENABLED="false" \
    GF_DIAGNOSTICS_PROFILING_ENABLED="false" \
    GF_DIAGNOSTICS_TRACING_ENABLED="false" \
    GOMEMLIMIT="96MiB" \
    GOGC="50"

RUN apk add --no-cache ca-certificates bash tzdata musl-utils && \
    addgroup -S -g 472 grafana && \
    adduser -S -u 472 -G grafana grafana && \
    mkdir -p /etc/grafana/provisioning /var/lib/grafana/plugins /var/log/grafana && \
    chown -R grafana:grafana /etc/grafana /var/lib/grafana /var/log/grafana

COPY --from=upstream --chown=grafana:grafana /usr/share/grafana /usr/share/grafana
COPY --from=upstream --chown=grafana:grafana /etc/grafana/grafana.ini /etc/grafana/grafana.ini
COPY --from=upstream /run.sh /run.sh

EXPOSE 3000
USER grafana
WORKDIR /usr/share/grafana
ENTRYPOINT ["/run.sh"]
