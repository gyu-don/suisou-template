# User Guide

ComfyUI docs: <https://docs.comfy.org/>

## Prerequisites

- Docker and Docker Compose
- Linux kernel 5.6+ (WireGuard)
- NVIDIA GPU + Container Toolkit (optional)

## Quick Start

```sh
docker compose -f compose.yaml -f examples/comfyui/compose.override.yaml up
```

Open <http://localhost:8188/>.

## GPU Acceleration

Uncomment the `deploy` section in `compose.override.yaml`:

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

## Storage

The example override mounts a named volume at `/app`, so the bundled ComfyUI checkout, custom nodes, downloaded models, and generated outputs persist across rebuilds.

## Custom Nodes

Use the ComfyUI-Manager panel (Manager > Custom Nodes Manager). Nodes are fetched from GitHub via the ComfyUI Registry; Python deps from PyPI.

Some custom nodes install PyTorch or NVIDIA Python wheels from extra package indexes. If needed, uncomment the optional `download*.pytorch.org` and `pypi.nvidia.com` entries in `router/config.toml`.

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

For gated models, add credential injection in `compose.override.yaml`:

```yaml
services:
  app:
    environment:
      - HUGGING_FACE_HUB_TOKEN=SUISOU__HUGGING_FACE_HUB_TOKEN
  router:
    environment:
      - HUGGING_FACE_HUB_TOKEN
```

Provide real secrets from your shell or a secrets manager at runtime. Do not commit them to `compose.override.yaml`.

## Remote Access

```sh
ssh -L 8188:localhost:8188 user@host
```
