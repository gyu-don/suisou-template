# Developer Guide

## Language

English for all code, configuration, and documentation.

## Verification

```sh
docker compose -f compose.yaml -f examples/open-webui/compose.override.yaml config -q
docker compose -f compose.yaml -f examples/open-webui/compose.override.yaml build
docker compose -f compose.yaml -f examples/open-webui/compose.override.yaml up -d
docker compose -f compose.yaml -f examples/open-webui/compose.override.yaml ps
docker compose -f compose.yaml -f examples/open-webui/compose.override.yaml logs router --tail=20
```

For routing/credential changes, run the full verification checklist in AGENTS-suisou.md.

## Project Layout

```
compose.override.yaml    # App-specific overrides (build, volumes, ports)
sandbox/Dockerfile       # Open WebUI image
router/config.toml       # Allowlist
```
