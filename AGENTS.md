# suisou-template

This is the template repository for building a [suisou](https://github.com/gyu-don/suisou)
sandbox around a specific application.  It is not itself a runnable
sandbox — use the **Use this template** button on GitHub to create a new
repository, then replace the placeholder `sandbox/` and `compose.yml`
`app` service with your application.

The core mechanics (router, wg-client, credential injection, allowlist
format) are documented in @AGENTS-suisou.md.  That document also lives
in every derived project and is expected to stay identical to the copy
here.

## Working on this repository

Different roles work on different parts of the tree:

- **Template maintainers** (people editing `router/`, `wg-client/`,
  `sandbox/entrypoint.sh`, or `AGENTS-suisou.md`): see
  [CONTRIBUTING.md](CONTRIBUTING.md) for how changes propagate to
  derived projects and what must be verified.
- **Template users** (people creating a new sandbox from this repo):
  see @AGENTS-template.md for the step-by-step flow.
- **Derived-project users / developers** (people running or extending
  an already-created sandbox): they never see this file; they work in
  their own repository, which contains its own `AGENTS.md`,
  `AGENTS-user.md`, and `AGENTS-developer.md`.

## Files that are invariant vs. project-specific

See the corresponding section of @AGENTS-suisou.md for the full list.
In short: `router/` and `wg-client/` plus this document and
`sandbox/entrypoint.sh` form the security boundary and are adopted
verbatim by derived projects; everything else is a placeholder or
example that is rewritten per project.
