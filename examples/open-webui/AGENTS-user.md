# User Guide

Open WebUI docs: <https://docs.openwebui.com/>

## Prerequisites

- Docker and Docker Compose
- Linux kernel 5.6+ (WireGuard)

## Quick Start

```sh
docker compose -f compose.yml -f examples/open-webui/compose.override.yml up
```

Open <http://localhost:3000/>.

## Configuration

### `router/config.toml`

Controls which domains the agent can access and how credentials are injected. Edit `examples/open-webui/router/config.toml` to match your needs.

### Credential injection

The router uses a naming convention to replace dummy credentials with real ones. This requires settings in two places — `compose.override.yml` configures both together:

```yaml
# compose.override.yml
services:
  app:
    environment:
      # Sandbox sees only the marker, never the real key
      - ANTHROPIC_API_KEY=SUISOU__ANTHROPIC_API_KEY
  router:
    environment:
      # Router receives the real key from the host environment
      - ANTHROPIC_API_KEY
```

When the router sees `SUISOU__ANTHROPIC_API_KEY` in an outbound HTTP header, it replaces it with the real `ANTHROPIC_API_KEY` from its own environment. The matching header is defined in `router/config.toml` under `[services.<name>.credentials]`.

### Secrets

Provide API key environment variables when starting. [Doppler](https://docs.doppler.com/docs/cli) is recommended.

Install the CLI, run `doppler login` (first time), then `doppler setup` in this directory (once per project). Both are interactive — run them in a regular terminal. See the [Doppler CLI docs](https://docs.doppler.com/docs/install-cli) for install instructions.

#### Setting secrets

Open the dashboard in a browser:

```sh
doppler open
```

Or via CLI — but be aware that any value written in a command is recorded in shell history and, if run through an AI agent, in its session context as well:

```sh
doppler secrets set ANTHROPIC_API_KEY=sk-ant-...
```

#### Running with secrets injected

```sh
doppler run -- docker compose -f compose.yml -f examples/open-webui/compose.override.yml up
```

If you need to specify a project or config explicitly (e.g. in CI):

```sh
doppler run -p PROJECT -c CONFIG -- docker compose -f compose.yml -f examples/open-webui/compose.override.yml up
```

#### Other options

```sh
# 1Password CLI
op run --env-file=.env -- docker compose -f compose.yml -f examples/open-webui/compose.override.yml up
```

Passing secrets inline (e.g. `ANTHROPIC_API_KEY=sk-ant-... docker compose -f compose.yml -f examples/open-webui/compose.override.yml up`) is not recommended — the value ends up in shell history and, if run through an AI agent, in its session context as well.

## Remote Access

Open WebUI listens on port `3000` on the host. To connect from another machine, forward the port over SSH:

```sh
ssh -L 3000:localhost:3000 <user>@<host>
```

Then open `http://localhost:3000/` in a browser.

## Services

### app

The Open WebUI container. Interact with it using standard Docker commands:

```sh
docker compose exec app bash
```

## External service integrations

### Moltbook (read-only)

[Moltbook](https://www.moltbook.com/) is an AI agent social network. All endpoints require an API key — anonymous reads are not possible.

**Step 1 — Register the agent (one-time, outside the sandbox)**

```sh
curl -s -X POST https://www.moltbook.com/api/v1/agents/register \
  -H "Content-Type: application/json" \
  -d '{"name": "YOUR_AGENT_NAME", "description": "YOUR_DESCRIPTION"}' | jq .
```

Save the returned `api_key`. The response also contains a `claim_url` and `verification_code`.

**Step 2 — Claim the account**

Open the `claim_url` in a browser, verify your email, then post the `verification_code` to X (Twitter). Moltbook checks the tweet to confirm ownership. The account becomes active once verified.

**Step 3 — Store the API key**

Set `MOLTBOOK_API_KEY` to the value returned in step 1, using whichever method you use for secrets (see [Secrets](#secrets)).

**Step 4 — Configure credential injection**

Add to `compose.override.yml`:

```yaml
services:
  app:
    environment:
      - MOLTBOOK_API_KEY=SUISOU__MOLTBOOK_API_KEY
  router:
    environment:
      - MOLTBOOK_API_KEY
```

**Step 5 — Add the service to `router/config.toml`**

Uncomment the Moltbook block in `router/config.toml`. Only `GET` is allowed, so the agent can read feeds, posts, comments, profiles, and search results but cannot post, comment, vote, follow, or modify anything.

> **Note:** Always use `www.moltbook.com` (with `www`). Without it, the server redirects and strips the Authorization header, exposing a broken request.

### Discord

Use Open WebUI's built-in model and tool integrations together with the router allowlist. The suisou-specific steps are below.

**Step 1 — Create a Discord bot**

In the [Discord Developer Portal](https://discord.com/developers/applications):

1. Create a new application and add a bot.
2. Under **Bot**, enable the following privileged Gateway Intents:
   - **Message Content Intent** (required)
   - **Server Members Intent** (recommended)
3. Under **OAuth2 → URL Generator**, select the `bot` and `applications.commands` scopes. Assign at minimum: Send Messages, Read Message History, Attach Files.
4. Copy the generated URL, open it in a browser, and invite the bot to your server.

**Step 2 — Store the bot token**

Set `DISCORD_BOT_TOKEN` to the token from the Developer Portal, using whichever method you use for secrets (see [Secrets](#secrets)).

**Step 3 — Configure credential injection**

Add to `compose.override.yml`:

```yaml
services:
  app:
    environment:
      - DISCORD_BOT_TOKEN=SUISOU__DISCORD_BOT_TOKEN
  router:
    environment:
      - DISCORD_BOT_TOKEN
```

**Step 4 — Add the service to `router/config.toml`**

Uncomment the Discord block in `router/config.toml`. It allows GET/POST/PUT/PATCH/DELETE on `discord.com` (REST API), GET on `cdn.discordapp.com` (attachments), and unrestricted access to `gateway.discord.gg` and `*.discord.gg` (WebSocket gateway).
