.PHONY: certs build run stop clean-data clean-images ps jenkins-log verify

certs:
	@bash scripts/generate-certs.sh

build: certs
	@docker compose -p jenkins --profile build-only build

run: certs
	@docker image inspect jenkins-agent-node:latest jenkins-agent-dotnet:latest >/dev/null 2>&1 || docker compose -p jenkins --profile build-only build
	@docker compose -p jenkins up -d

verify:
	@bash scripts/verify.sh

stop:
	@docker compose -p jenkins down --remove-orphans

clean-data:
	@docker compose -p jenkins down -v --remove-orphans

clean-images:
	@docker image prune -f

ps:
	@docker compose -p jenkins ps

jenkins-log:
	@docker compose -p jenkins logs -f controller
