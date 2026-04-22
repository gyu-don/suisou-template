# Suisou core architecture

This document describes the invariant security model and mechanics of a
suisou sandbox.  It is maintained in the `suisou-template` repository and
is expected to be adopted verbatim by every derived project.  Local edits
to this file in a derived project are discouraged — pull updates from the
template instead (see "Updating from the template" at the bottom).

Agents working on a derived project should treat the rules here as hard
constraints on what may be changed.

## Threat model

Suisou sandboxes a single application that may run arbitrary third-party
code (agents, custom nodes, plugins).  The goals are:

1. The application cannot reach the internet except through an
   allowlisted set of HTTP(S) endpoints.
2. The application never sees the real secrets used to authenticate those
   calls — it only sees placeholder markers, which the router substitutes
   at egress.
3. The application cannot disable or reconfigure the network filtering
   from inside its container.

## Services

A suisou stack has three services, defined in `compose.yaml`.

### `app` (sandbox)

The application container.  In the template its Compose service is named
`app`; derived projects rename it.  It:

- runs without `NET_ADMIN` or `NET_RAW` (Compose `cap_add` is absent);
- shares its network namespace with `wg-client` via
  `network_mode: "service:wg-client"`, so every packet it sends is
  subject to the kill-switch described below;
- mounts the read-only `mitmproxy-ca` volume and installs the certificate
  at startup via `sandbox/entrypoint.sh`;
- publishes no ports of its own — any port the application listens on is
  made reachable via `wg-client.ports`.

### `wg-client`

A minimal WireGuard client that establishes a tunnel to `router` and
enforces the kill-switch via iptables.  It:

- has `NET_ADMIN` and `NET_RAW` so it can set up `wg0` and configure
  iptables, and drops every other capability (`cap_drop: ALL`);
- routes the WireGuard handshake via `eth0` to `router`, but replaces the
  default route with `wg0`, so container-originated traffic has no escape
  path other than the tunnel;
- marks NEW inbound connections on `eth0` with `CONNMARK 0x1`, restores
  that mark on reply packets, and routes marked packets back through the
  original gateway via a dedicated routing table (100).  This makes
  published-port connections (LAN access to the application UI) work
  without weakening the kill-switch for container-originated traffic,
  which carries no mark;
- signals readiness by touching `/tmp/wg-ready` (used by the healthcheck).

The application container cannot modify these rules because it shares the
netns but has no capability to change iptables or routing.

### `router`

mitmproxy in WireGuard mode (`--mode wireguard`).  It:

- terminates the WireGuard tunnel from `wg-client` on UDP/51820;
- transparently intercepts all HTTP and HTTPS traffic, producing a
  mitmproxy-signed certificate that the sandbox trusts because the CA was
  installed at startup;
- loads `router/addon.py`, which applies the allowlist in
  `/etc/suisou/config.toml` (mounted from `router/config.toml`) and
  performs credential injection;
- publishes the CA certificate to the `mitmproxy-ca` volume so the
  sandbox can read it;
- signals readiness by writing `wireguard.conf` into its config
  directory (used by the healthcheck).

The router is attached to two networks: `tunnel` (shared with
`wg-client`) and `external` (the actual egress).  The sandbox has no
direct path to `external`.

## Allowlist (`router/config.toml`)

Each `[services.<name>]` block groups endpoints that the application may
call, plus optional credential-injection rules.

### Endpoints

An endpoint entry is matched when **all** of the following hold:

| Field | Match rule |
|---|---|
| `domain` | fnmatch against the logical hostname (see Host-header verification below). |
| `methods` | HTTP method, case-insensitive.  Omitted = any method. |
| `paths` | fnmatch against the request path.  Omitted = any path. |
| `ports` | Integer equality against the destination port.  Omitted = any port. |
| `allow_plain_http` | Must be `true` to allow non-TLS requests to the domain. |

Any request that does not match at least one endpoint is blocked with a
403 response.  Non-HTTP TCP connections and non-DNS UDP connections are
killed by the `tcp_start` / `udp_start` hooks in `addon.py`.

### Host-header verification

`addon.py` derives the logical hostname from `flow.request.pretty_host`
(the `Host` or `:authority` header).  Because this header is attacker-
controlled, it is cross-checked against a transport-level signal before
being used for allowlist matching:

- **TLS**: `pretty_host` must equal the SNI.  mitmproxy has already
  verified SNI against the upstream certificate, so this anchors the
  domain name to the cryptographic identity of the server.
- **Plain HTTP**: there is no transport-level signal, so `pretty_host`
  is trusted only when the matching endpoint sets
  `allow_plain_http = true`.  Without that flag, plain-HTTP requests are
  blocked.

### Credential injection

A `[services.<name>.credentials]` block declares `{ header, env }`.  When
an outbound request to that service contains the literal string
`SUISOU__<env>` in the named header, the router replaces that marker
with the real value of `<env>` from its own environment.  The sandbox
container therefore only ever sees the marker.

Injection also runs on client-to-server WebSocket text payloads that
contain the `SUISOU__` prefix and parse as JSON — this handles cases
like Discord's gateway IDENTIFY op, where the bot token travels inside a
JSON message rather than an HTTP header.  Replacement is scoped to the
env vars declared for a service whose domain matches the WebSocket host,
so a marker for one service cannot be expanded in a connection to
another service.

### DNS

The sandbox uses `10.0.0.53`, mitmproxy's built-in WireGuard resolver, as
set by `sandbox/entrypoint.sh`.  Non-DNS UDP is killed by the router, so
there is no alternate resolver path.

## Files that must not be modified in a derived project

The following are the security boundary.  Never edit them locally; any
bug fix or feature must flow through the `suisou-template` repository so
it applies to every derived project.

- `compose.yaml` (base service definitions; customize via `compose.override.yaml`)
- `router/Dockerfile`
- `router/addon.py`
- `wg-client/Dockerfile`
- `wg-client/entrypoint.sh`
- `sandbox/entrypoint.sh` (the CA-install and DNS-setup logic; the
  trailing `exec` line may be customized in place if needed)
- This file (`AGENTS-suisou.md`)

## Files that a derived project owns

These exist in the template as placeholders or examples and are expected
to be rewritten in each derived project:

- `sandbox/Dockerfile` — replaced with the application's image.
- `compose.override.yaml` — app-specific overrides: build context, volumes,
  ports, and credential injection.  Never committed (contains or references
  secrets).
- `router/config.toml` — copied from `config.example.toml` and edited to
  enable only the allowlist services the application needs.
- `README.md`, `AGENTS.md`, `AGENTS-user.md`, `AGENTS-developer.md` —
  rewritten for the specific application.

## Verification checklist

When any file listed above as "must not be modified" changes locally
(e.g. while integrating a template update), run at minimum:

```sh
docker compose config -q
docker compose build && docker compose up -d
docker compose ps
docker compose logs router --tail=20
```

Against the live stack, verify:

- An allowlisted HTTPS endpoint (e.g. `GET https://github.com/`) returns
  `200` from inside the sandbox.
- A non-allowlisted HTTPS endpoint (e.g. `GET https://example.com/`)
  returns `403`.
- A `SUISOU__<ENV>` marker for an env var declared on the matching
  service is replaced with the real value.
- A `SUISOU__<ENV>` marker for an env var declared only on a different
  service stays as the marker.

These are the core invariants of the sandbox and are not optional smoke
tests.

## Updating from the template

`suisou-template` is consumed as a GitHub template — derived projects
have no shared history with it.  To pull updates into an existing
derived project:

```sh
git remote add template https://github.com/gyu-don/suisou-template.git
git fetch template
git checkout template/main -- \
    compose.yaml \
    router/Dockerfile router/addon.py \
    wg-client/Dockerfile wg-client/entrypoint.sh \
    sandbox/entrypoint.sh \
    AGENTS-suisou.md
git diff --cached
git commit -m "Sync suisou-template core"
```

Review the diff carefully before committing.  Any merge conflict with
files outside the list above is out of scope for this sync — those files
are owned by the derived project.
