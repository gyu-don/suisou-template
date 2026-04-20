# Creating a new sandbox from suisou-template

This guide is for a user who wants to sandbox a specific application
(ComfyUI, Open WebUI, a custom agent runtime, etc.) using this template.

Start by skimming @AGENTS-suisou.md for the security model and the list
of files that must not be modified locally — those constraints apply to
the project you are about to create.

## 1. Create the repository

On GitHub, open this repository and click **Use this template →
Create a new repository**.  Clone the new repository locally.  The
template and your copy share no git history; updates to the template
are pulled in manually via a `template` remote when needed (see
"Updating from the template" in @AGENTS-suisou.md).

## 2. Remove template-only files

These files exist only in the template and are not part of a derived
project:

```sh
rm AGENTS-template.md CONTRIBUTING.md
rm -rf examples/
```

## 3. Replace placeholders

The base `compose.yml` is fixed and should not be modified.  All
app-specific configuration goes in `compose.override.yml`.

Copy from an example if one exists:

```sh
# Example: ComfyUI
cp examples/comfyui/sandbox/Dockerfile sandbox/Dockerfile
cp examples/comfyui/router/config.toml router/config.toml
cp examples/comfyui/compose.override.yml compose.override.yml
```

Then edit `compose.override.yml` to adjust paths (change
`examples/comfyui/...` to `./...`):

```yaml
services:
  app:
    build:
      context: sandbox              # was: examples/comfyui/sandbox
    volumes:
      - app-data:/app/data

  wg-client:
    ports:
      - "8080:8080"

  router:
    environment:
      # - ANTHROPIC_API_KEY

volumes:
  app-data:
```

If no matching example exists:

- `sandbox/Dockerfile` — create your application image, preserving the
  `ENTRYPOINT ["suisou-entrypoint.sh"]` line.
- `router/config.toml` — copy from `router/config.example.toml` and
  enable only the services your application needs.
- `compose.override.yml` — copy from `compose.override.example.yml`
  and customize build context, volumes, and ports.

## 4. Wire up credentials

Add credential injection to `compose.override.yml`:

```yaml
services:
  app:
    environment:
      - ANTHROPIC_API_KEY=SUISOU__ANTHROPIC_API_KEY  # sandbox sees marker

  router:
    environment:
      - ANTHROPIC_API_KEY  # router receives real value
```

Provide real values via Doppler, 1Password CLI, or another secrets
manager at runtime — do not commit them or pass them inline.

## 5. Rewrite the documentation

The template ships `AGENTS.md` describing itself; your project needs
its own.  A minimal starting structure:

```
README.md              — 1–2 paragraph overview, pointing at AGENTS-user.md.
AGENTS.md              — short, imports AGENTS-suisou.md and other guides.
AGENTS-suisou.md       — kept as-is; synced from the template.
AGENTS-user.md         — how to run: env vars, ports, Doppler setup.
AGENTS-developer.md    — app-specific contributor notes.
CLAUDE.md              — @AGENTS.md.
```

Delete this `AGENTS-template.md` once you have finished the steps
above.

## 6. Build and verify

```sh
docker compose config -q
docker compose build && docker compose up -d
docker compose ps
```

Run the verification checklist from @AGENTS-suisou.md: allowed request
succeeds, non-allowlisted request is blocked, credential marker is
substituted only for the declaring service.
