#!/bin/bash
# Suisou sandbox entrypoint.
#
# This script is part of the suisou-template core: it installs the
# mitmproxy CA and points DNS at the WireGuard resolver so that all
# outbound traffic from this container can be intercepted and filtered
# by the router service.  The final `exec` runs the container's CMD.
#
# Customization points (edit if needed):
#   - If your application needs to drop to a non-root user, replace the
#     final `exec "$@"` with `exec gosu <user> "$@"` and make sure gosu
#     is installed in sandbox/Dockerfile.
#   - If your runtime reads a CA bundle from a non-standard env var, add
#     an `export` below alongside NODE_EXTRA_CA_CERTS.
#
# Do not change the CA installation or DNS setup: they are the glue that
# makes the allowlist and credential-injection enforced by the router
# apply to this container.
set -eu

# --------------------------------------------------------------------------
# Install the mitmproxy CA certificate (requires root).
# The router writes it into the shared volume mounted at /mitmproxy-ca.
# --------------------------------------------------------------------------
CA_SRC="/mitmproxy-ca/mitmproxy-ca-cert.pem"
CA_DST="/usr/local/share/ca-certificates/mitmproxy-ca.crt"
for _ in $(seq 1 30); do
  [ -f "$CA_SRC" ] && break
  sleep 0.5
done
if [ -f "$CA_SRC" ]; then
  cp "$CA_SRC" "$CA_DST"
  update-ca-certificates --fresh > /dev/null 2>&1
  # Runtimes that don't read the system trust store need an explicit pointer.
  export NODE_EXTRA_CA_CERTS="$CA_DST"
  export REQUESTS_CA_BUNDLE="$CA_DST"
  export SSL_CERT_FILE="$CA_DST"
  export CURL_CA_BUNDLE="$CA_DST"
fi

# --------------------------------------------------------------------------
# DNS: use mitmproxy's WireGuard resolver (always 10.0.0.53).
# --------------------------------------------------------------------------
echo "nameserver 10.0.0.53" > /etc/resolv.conf

exec "$@"
