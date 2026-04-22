# Developer Guide

## Language

English for all code, configuration, and documentation.

## Verification

```sh
docker compose -f compose.yaml -f examples/comfyui/compose.override.yaml config -q
docker compose -f compose.yaml -f examples/comfyui/compose.override.yaml build
docker compose -f compose.yaml -f examples/comfyui/compose.override.yaml up -d
docker compose -f compose.yaml -f examples/comfyui/compose.override.yaml ps
docker compose -f compose.yaml -f examples/comfyui/compose.override.yaml logs router --tail=20
```

For routing/credential changes, run the full verification checklist in AGENTS-suisou.md.

## Project Layout

```
compose.override.yaml    # App-specific overrides (build, volumes, ports)
sandbox/Dockerfile       # ComfyUI image
router/config.toml       # Allowlist (GitHub, registry.comfy.org, PyPI, uv, optional model/package hosts)
```
