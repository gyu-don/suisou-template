# Suisou — ComfyUI

A Docker Compose sandbox for [ComfyUI](https://www.comfy.org/) with controlled network access and credential injection.

[ComfyUI-Manager](https://github.com/Comfy-Org/ComfyUI-Manager) is pre-installed. The allowlist permits GitHub (read-only), `registry.comfy.org`, PyPI, and `astral.sh`. Model hosting (HuggingFace, CivitAI) is commented out by default.

## Quick Start

```sh
# From repository root
docker compose -f compose.yml -f examples/comfyui/compose.override.yml up
```

Open http://localhost:8188/.

## Documentation

- [AGENTS-user.md](AGENTS-user.md) — setup, GPU acceleration, credentials.
- [AGENTS.md](AGENTS.md) — architecture overview.
