# syntax=docker/dockerfile:1.7
#
# Placeholder sandbox image.  Replace this file with a Dockerfile that
# builds your application, while preserving the ENTRYPOINT line so the
# CA certificate and DNS setup in entrypoint.sh still run.
#
# See examples/ for real implementations (ComfyUI, Open WebUI, etc.).

FROM alpine:3.21

RUN apk add --no-cache ca-certificates bash

COPY --chmod=755 entrypoint.sh /usr/local/bin/suisou-entrypoint.sh

ENTRYPOINT ["suisou-entrypoint.sh"]
CMD ["sh", "-c", "echo 'Replace sandbox/Dockerfile with your application.' && sleep infinity"]
