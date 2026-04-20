# suisou-template

Template for building a [suisou](https://github.com/gyu-don/suisou)-style
sandbox around a specific application.  The sandbox routes all outbound
traffic from the application through a mitmproxy-in-WireGuard router that
enforces a domain allowlist and transparently injects secrets, so the
application container can run untrusted third-party code without
exfiltrating data or credentials.

## Using this template

1. Click **Use this template → Create a new repository** on GitHub.
2. Clone the new repository and follow the step-by-step guide in
   [AGENTS-template.md](AGENTS-template.md).
3. Keep `compose.yml`, `router/`, `wg-client/`, `sandbox/entrypoint.sh`, and
   `AGENTS-suisou.md` unmodified in your derived project — they are the
   security boundary and are kept in sync with this template.

Existing implementations:

- [examples/comfyui/](examples/comfyui/) — ComfyUI (image generation,
  custom nodes that execute arbitrary Python).
- [examples/open-webui/](examples/open-webui/) — Open WebUI (LLM chat interface).

Run an example from the repo root:

```sh
docker compose -f compose.yml -f examples/comfyui/compose.override.yml up
```

## Contributing to the template itself

See [CONTRIBUTING.md](CONTRIBUTING.md).  Changes to files in the
security boundary need the verification checklist in
[AGENTS-suisou.md](AGENTS-suisou.md) run against a live stack before
merging, and the template maintainer is responsible for notifying
derived projects when a security-relevant change lands.

## License

[MIT](LICENSE) — Copyright (c) 2026 gyu-don
