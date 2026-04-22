# Suisou — Open WebUI

A Docker Compose sandbox for [Open WebUI](https://docs.openwebui.com/) with controlled network access and credential injection.

The router (mitmproxy) enforces a domain allowlist and transparently injects secrets so they never touch the sandbox.

## Quick Start

```sh
# From repository root
docker compose -f compose.yaml -f examples/open-webui/compose.override.yaml up
```

Open http://localhost:3000/.

## Documentation

- [AGENTS-user.md](AGENTS-user.md) — setup, credentials, integrations.
- [AGENTS.md](AGENTS.md) — architecture overview.
