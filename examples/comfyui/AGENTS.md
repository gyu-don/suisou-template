# suisou

A Docker Compose-based sandbox environment for [ComfyUI](https://www.comfy.org/).

## Architecture

- **app** — ComfyUI with [ComfyUI-Manager](https://github.com/Comfy-Org/ComfyUI-Manager) pre-installed. Shares the `wg-client` network namespace, so all outbound traffic flows through the WireGuard tunnel.
- **wg-client** — WireGuard client with iptables kill-switch. The app container cannot alter firewall rules.
- **router** — mitmproxy in WireGuard mode. Enforces domain allowlist (`router/config.toml`) and credential injection.

Default allowlist: GitHub (read-only), `registry.comfy.org`, PyPI, `astral.sh`. Model hosting is commented out.

## Documentation

- [AGENTS-user.md](AGENTS-user.md) — setup, GPU, credentials.
- [AGENTS-developer.md](AGENTS-developer.md) — contributor guide.
