#!/usr/bin/env bash
set -euo pipefail

JENKINS_USER="${JENKINS_ADMIN_ID:-admin}"
JENKINS_PASS="${JENKINS_ADMIN_PASSWORD:-admin}"
cookie_jar_path="$(mktemp)"
trap 'rm -f "$cookie_jar_path"' EXIT

CURL_TLS_OPTS=(-k)
if command -v mkcert >/dev/null 2>&1 && [[ -f "$(mkcert -CAROOT)/rootCA.pem" ]]; then
  CURL_TLS_OPTS=(--cacert "$(mkcert -CAROOT)/rootCA.pem")
fi

auth_curl() {
  curl -fsS "${CURL_TLS_OPTS[@]}" -u "${JENKINS_USER}:${JENKINS_PASS}" "$@"
}

poll_until() {
  local max_attempts="$1"
  local sleep_seconds="$2"
  local check_cmd="$3"
  for _ in $(seq 1 "$max_attempts"); do
    if eval "$check_cmd"; then
      return 0
    fi
    sleep "$sleep_seconds"
  done
  return 1
}

echo "1/5 Verifying HTTPS Ingress Proxy, HTTP->HTTPS redirect, anonymous lock, and Controller login..."
curl -fsS http://localhost/healthz >/dev/null
redirect_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
if [[ "$redirect_code" != "301" ]]; then
  echo "    ! Expected HTTP 301 redirect on http://localhost/, got ${redirect_code}"
  exit 1
fi
anon_code=$(curl -s "${CURL_TLS_OPTS[@]}" -o /dev/null -w "%{http_code}" https://localhost/api/json)
if [[ "$anon_code" != "403" ]]; then
  echo "    ! Expected HTTP 403 for unauthenticated Controller access, got ${anon_code}"
  exit 1
fi
auth_curl https://localhost/api/json >/dev/null

# Verify interactive browser form login over HTTPS (/j_spring_security_check)
login_crumb=$(curl -fsS "${CURL_TLS_OPTS[@]}" -c "$cookie_jar_path" https://localhost/login | sed -n 's/.*name="Jenkins-Crumb" type="hidden" value="\([^"]*\)".*/\1/p')
login_location=$(curl -s -i "${CURL_TLS_OPTS[@]}" -b "$cookie_jar_path" -X POST https://localhost/j_spring_security_check \
  -H "Origin: https://localhost" \
  -H "Referer: https://localhost/login" \
  --data-urlencode "j_username=${JENKINS_USER}" \
  --data-urlencode "j_password=${JENKINS_PASS}" \
  --data-urlencode "from=/" \
  --data-urlencode "Jenkins-Crumb=${login_crumb}" \
  --data-urlencode "Submit=" | tr -d '\r' | awk '/^Location:/ {print $2}')
if [[ "$login_location" == *loginError* ]]; then
  echo "    ! Interactive Jenkins form login failed (redirected to ${login_location})"
  exit 1
fi
echo "    ✓ HTTPS Ingress Proxy (https://localhost/), anonymous read blocked (403) & interactive login succeeded"

echo "2/5 Verifying route-scoped rate limiter on https://localhost/login (expecting HTTP 429 on burst)..."
login_response_codes=$(seq 1 25 | xargs -I{} -P 12 curl -s "${CURL_TLS_OPTS[@]}" -o /dev/null -w "%{http_code}\n" https://localhost/login || true)
if grep -q "429" <<< "$login_response_codes"; then
  echo "    ✓ Route-scoped rate limiter returned HTTP 429 on /login burst"
else
  echo "    ! Failed to observe 429 (codes: $(echo "$login_response_codes" | sort -u | tr '\n' ' '))"
  exit 1
fi

echo "3/5 Verifying Telemetry Collector (Prometheus) target health..."
poll_until 15 2 "curl -fsS http://127.0.0.1:9090/api/v1/targets | grep -q '\"health\":\"up\"'"
curl -fsS http://127.0.0.1:9090/api/v1/targets | python3 -c '
import sys, json
targets = json.load(sys.stdin)["data"]["activeTargets"]
jenkins_up = any(t["labels"].get("job") == "jenkins" and t["health"] == "up" for t in targets)
if not jenkins_up:
    raise SystemExit("Prometheus jenkins target is not up: " + str(targets))
print("    ✓ Prometheus is actively scraping Controller (/prometheus/)")
'

echo "4/5 Verifying lightweight Observability Dashboard (Grafana) over HTTPS..."
grafana_health=$(curl -fsS "${CURL_TLS_OPTS[@]}" https://localhost/grafana/api/health)
grep -q '"database": "ok"' <<< "$grafana_health"
grafana_dash=$(auth_curl https://localhost/grafana/api/dashboards/uid/jenkins-testops)
grep -q '"uid":"jenkins-testops"' <<< "$grafana_dash"
grafana_login=$(curl -fsS "${CURL_TLS_OPTS[@]}" -X POST https://localhost/grafana/login \
  -H "Content-Type: application/json" \
  -H "Origin: https://localhost" \
  -d "{\"user\":\"${JENKINS_USER}\",\"password\":\"${JENKINS_PASS}\"}")
grep -q "Logged in" <<< "$grafana_login"
echo "    ✓ Grafana HTTPS login & dashboard 'jenkins-testops' verified at https://localhost/grafana/"

echo "5/5 Triggering Seed Pipeline (BasicEnvTest) across JDK 25, Node.js 26 (node-caged) & .NET 10 Build Agents..."
rm -f "$cookie_jar_path"
crumb_header=$(auth_curl -c "$cookie_jar_path" 'https://localhost/crumbIssuer/api/json' | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['crumbRequestField'] + ':' + d['crumb'])")
next_build=$(auth_curl https://localhost/job/BasicEnvTest/api/json | python3 -c "import sys,json; print(json.load(sys.stdin)['nextBuildNumber'])")
auth_curl -b "$cookie_jar_path" -X POST -H "$crumb_header" https://localhost/job/BasicEnvTest/build >/dev/null

check_build_done() {
  local build_json
  build_json=$(auth_curl "https://localhost/job/BasicEnvTest/${next_build}/api/json" 2>/dev/null || true)
  python3 -c "import sys, json; d=json.loads(sys.stdin.read()); raise SystemExit(0 if (d.get('building') is False and d.get('result') is not None) else 1)" <<< "$build_json" 2>/dev/null
}

poll_until 60 2 check_build_done

console_output=$(auth_curl "https://localhost/job/BasicEnvTest/${next_build}/consoleText")
grep -q 'openjdk version "25\.' <<< "$console_output"
grep -q "v26\." <<< "$console_output"
grep -q "10.0." <<< "$console_output"
grep -q "postgres (PostgreSQL) 18" <<< "$console_output"
grep -q "Finished: SUCCESS" <<< "$console_output"
echo "    ✓ Seed Pipeline #${next_build} passed on JDK 25 LTS, Node.js 26 LTS (node-caged), .NET 10.0 & ephemeral Postgres 18 sidecar"
echo "All seams verified!"


