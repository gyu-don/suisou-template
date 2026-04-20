# suisou

A Docker Compose-based sandbox environment for [Open WebUI](https://docs.openwebui.com/).

## Architecture

- **app** — Open WebUI container. Shares the `wg-client` network namespace, so all outbound traffic flows through the WireGuard tunnel.
- **wg-client** — WireGuard client with iptables kill-switch. The app container cannot alter firewall rules.
- **router** — mitmproxy in WireGuard mode. Enforces domain allowlist (`router/config.toml`) and credential injection.

## Documentation

- [AGENTS-user.md](AGENTS-user.md) — setup and usage.
- [AGENTS-developer.md](AGENTS-developer.md) — contributor guide.
