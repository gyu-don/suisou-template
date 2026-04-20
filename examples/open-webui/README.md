# Suisou

A Docker Compose sandbox for [Open WebUI](https://docs.openwebui.com/) with controlled network access and secure credential injection.

The router (mitmproxy) sits between the Open WebUI container and the internet, enforcing a domain allowlist and transparently injecting secrets so they never touch the sandbox.

## Quick Start

```sh
# 1. Configure the router allowlist
cp router/config.example.toml router/config.toml
# Edit router/config.toml to add your services

# 2. Create compose.override.yml for credentials (see compose.override.example.yml)
cp compose.override.example.yml compose.override.yml

# 3. Build and start
docker compose build
ANTHROPIC_API_KEY=sk-ant-... docker compose up
```

Open WebUI is available at http://localhost:3000/.

## Documentation

See [AGENTS-user.md](AGENTS-user.md) for setup details and configuration, and [AGENTS.md](AGENTS.md) for architecture overview. AI agents working on this repo should also read [AGENTS-developer.md](AGENTS-developer.md).

## License

[MIT](LICENSE) -- Copyright (c) 2026 gyu-don
