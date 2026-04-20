# User Guide

ComfyUI docs: <https://docs.comfy.org/>

## Prerequisites

- Docker and Docker Compose
- Linux kernel 5.6+ (WireGuard)
- NVIDIA GPU + Container Toolkit (optional)

## Quick Start

```sh
docker compose -f compose.yml -f examples/comfyui/compose.override.yml up
```

Open <http://localhost:8188/>.

## GPU Acceleration

Uncomment the `deploy` section in `compose.override.yml`:

```yaml
services:
  app:
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
```

Requires [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html).

## Custom Nodes

Use the ComfyUI-Manager panel (Manager > Custom Nodes Manager). Nodes are fetched from GitHub via the ComfyUI Registry; Python deps from PyPI.

## Model Downloads

HuggingFace and CivitAI are blocked by default. To enable, uncomment in `router/config.toml`:

```toml
[services.huggingface]
endpoints = [
  { domain = "huggingface.co",         methods = ["GET"] },
  { domain = "*.huggingface.co",       methods = ["GET"] },
  ...
]
```

For gated models, add credential injection in `compose.override.yml`:

```yaml
services:
  app:
    environment:
      - HUGGING_FACE_HUB_TOKEN=SUISOU__HUGGING_FACE_HUB_TOKEN
  router:
    environment:
      - HUGGING_FACE_HUB_TOKEN
```

## Remote Access

```sh
ssh -L 8188:localhost:8188 user@host
```
