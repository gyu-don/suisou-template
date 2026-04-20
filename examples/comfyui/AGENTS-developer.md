# Developer Guide

## Language

English for all code, configuration, and documentation.

## Verification

```sh
docker compose -f compose.yml -f examples/comfyui/compose.override.yml config -q
docker compose -f compose.yml -f examples/comfyui/compose.override.yml build
docker compose -f compose.yml -f examples/comfyui/compose.override.yml up -d
docker compose -f compose.yml -f examples/comfyui/compose.override.yml ps
docker compose -f compose.yml -f examples/comfyui/compose.override.yml logs router --tail=20
```

For routing/credential changes, run the full verification checklist in AGENTS-suisou.md.

## Project Layout

```
compose.override.yml     # App-specific overrides (build, volumes, ports)
sandbox/Dockerfile       # ComfyUI image
router/config.toml       # Allowlist (GitHub, registry.comfy.org, PyPI, uv)
```
