# Developer Guide

## Language

English for all code, configuration, and documentation.

## Verification

```sh
docker compose -f compose.yml -f examples/open-webui/compose.override.yml config -q
docker compose -f compose.yml -f examples/open-webui/compose.override.yml build
docker compose -f compose.yml -f examples/open-webui/compose.override.yml up -d
docker compose -f compose.yml -f examples/open-webui/compose.override.yml ps
docker compose -f compose.yml -f examples/open-webui/compose.override.yml logs router --tail=20
```

For routing/credential changes, run the full verification checklist in AGENTS-suisou.md.

## Project Layout

```
compose.override.yml     # App-specific overrides (build, volumes, ports)
sandbox/Dockerfile       # Open WebUI image
router/config.toml       # Allowlist
```
