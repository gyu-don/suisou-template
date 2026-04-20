# Contributing to suisou-template

This repository is the upstream for every suisou-based sandbox.  Changes
here flow one-way, via `git remote add template`, into derived projects
when their maintainers choose to sync.  There is no automatic
propagation — so changes must be designed with that reality in mind.

The target audience for this document is the template maintainer.
Users who are creating a new sandbox from this template want
@AGENTS-template.md instead.

## Language and style

- English for all code, configuration, and documentation.
- Keep configuration minimal and explicit; prefer standard Docker and
  Compose idioms over custom abstractions.
- Do not duplicate information that is already expressed in code.  If a
  doc restates what a file shows, point to the file instead.

## Version control

This repository uses [jj](https://martinvonz.github.io/jj/).  One change
per logical unit (a feature, a fix, a config change); don't bundle
unrelated changes.  Commit messages use imperative mood; include a body
whenever the "why" is not obvious from the diff — consumers will read
these messages to decide whether to pull a change.

## Scope

The template tracks the security-boundary surface and the placeholders
that every derived project starts from.  Specifically:

- `router/` and `wg-client/`: the enforcement layer.
- `sandbox/entrypoint.sh`: the CA-install and DNS-setup glue.
- `sandbox/Dockerfile` and `compose.yml`: placeholders that every
  derived project rewrites.  Changes here should keep them small and
  unopinionated.
- `router/config.example.toml`: a menu of common allowlist services;
  opinionated only insofar as it shows good defaults.
- Documentation (`AGENTS*.md`, `CONTRIBUTING.md`, `README.md`).
- `examples/`: reference implementations of concrete sandboxes that
  validate the template design and give users a starting point to copy.

What does **not** belong here:

- Application-specific sandbox images (those live in derived projects,
  with a reference copy under `examples/`).
- Project-specific `router/config.toml` (derived-project concern).
- Personal credentials or `compose.override.yml`.

## Security-critical changes

Any change to `router/addon.py`, `wg-client/entrypoint.sh`, or
`sandbox/entrypoint.sh` is part of the security boundary.  Before
merging:

- Run the verification checklist in @AGENTS-suisou.md against a live
  stack.
- Describe, in the commit body, what threat model the change affects
  and why the change is correct in the worst case (not just the happy
  path).
- Update @AGENTS-suisou.md in the same change if the observable
  semantics shift — derived projects rely on that document being an
  accurate reference.

## Propagation to derived projects

When you merge a security-critical change, open a tracking issue or PR
in each existing derived project pointing at the upstream commit and
the `git checkout template/main -- <paths>` recipe from
@AGENTS-suisou.md.  Users cannot tell from their local repository that
a fix exists upstream; the template maintainer is the one who notifies
them.

## Updating `examples/`

`examples/<app>/` should build against the current `router/` and
`wg-client/` and should pass the verification checklist.  When you
change the placeholder `sandbox/Dockerfile` or `compose.yml`, make the
analogous change in each example so that a user who copies from
`examples/` ends up with a working sandbox on the first try.

## Verification before pushing

At minimum:

```sh
docker compose config -q
```

For changes that touch the enforcement layer or entrypoint, bring up a
full stack built from one of the examples and run the @AGENTS-suisou.md
verification checklist against it.
