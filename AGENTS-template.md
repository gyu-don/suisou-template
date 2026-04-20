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

Rename the Compose service from `app` to your application name, pick an
image or build context, and publish the ports your application needs on
`wg-client`:

- `sandbox/Dockerfile` — start from one of `examples/<app>/sandbox/` if
  a matching example exists; otherwise replace the placeholder image and
  preserve the `ENTRYPOINT` line.
- `compose.yml` — rename the `app` service, add per-app volumes, and
  uncomment `wg-client.ports` with the port list you want exposed.
- `sandbox/entrypoint.sh` — usually untouched.  The only customization
  that belongs here is the final `exec` line (e.g. switching to
  `exec gosu <user> "$@"` if your Dockerfile needs to drop from root).

## 4. Configure the allowlist

Copy `router/config.example.toml` to `router/config.toml` and enable
only the `[services.<name>]` blocks your application needs.  See the
allowlist section of @AGENTS-suisou.md for the matching semantics.

## 5. Wire up credentials

Copy `compose.override.example.yml` to `compose.override.yml` and
declare your secrets with the `SUISOU__<ENV>` marker convention on the
sandbox side and the plain env-var name on the router side.  Provide
the real values via Doppler, 1Password CLI, or another secrets manager
at runtime — do not commit them or pass them inline on the command
line.

## 6. Rewrite the documentation

The template ships `AGENTS.md` describing itself; your project needs
its own.  A minimal starting structure:

```
README.md              — 1–2 paragraph overview of the derived sandbox,
                         pointing at AGENTS-user.md for setup.
AGENTS.md              — short, imports AGENTS-suisou.md and the user
                         and developer guides via @-imports.
AGENTS-suisou.md       — kept as-is; synced from the template.
AGENTS-user.md         — how to run this sandbox: required env vars,
                         exposed ports, Doppler setup.
AGENTS-developer.md    — app-specific contributor notes: how to test
                         the particular application, what makes this
                         allowlist opinionated, etc.
CLAUDE.md              — @AGENTS.md.
```

Delete this `AGENTS-template.md` once you have finished the steps
above.

## 7. Build and verify

```sh
docker compose config -q
docker compose build && docker compose up -d
docker compose ps
```

Run the verification checklist from @AGENTS-suisou.md: allowed request
succeeds, non-allowlisted request is blocked, credential marker is
substituted only for the declaring service.
