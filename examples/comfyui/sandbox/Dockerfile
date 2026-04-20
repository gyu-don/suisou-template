# syntax=docker/dockerfile:1.7

FROM pytorch/pytorch:2.5.1-cuda12.4-cudnn9-runtime

USER root

RUN --mount=type=cache,id=suisou-sandbox-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=suisou-sandbox-apt-lists,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates git

WORKDIR /app

RUN --mount=type=cache,id=suisou-comfyui-pip,target=/root/.cache/pip \
    git clone https://github.com/comfyanonymous/ComfyUI . \
    && pip install uv \
    && uv pip install --system -r requirements.txt

# ComfyUI-Manager for custom node and model management
RUN --mount=type=cache,id=suisou-comfyui-pip,target=/root/.cache/pip \
    git clone https://github.com/Comfy-Org/ComfyUI-Manager custom_nodes/ComfyUI-Manager \
    && uv pip install --system -r custom_nodes/ComfyUI-Manager/requirements.txt

COPY --chmod=755 entrypoint.sh /usr/local/bin/suisou-entrypoint.sh

ENTRYPOINT ["suisou-entrypoint.sh"]
CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
