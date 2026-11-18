## Agent skills

### Branch and pull request workflow

Create a separate `codex/<issue-number>-<description>` branch from `dev` for every specification and each subtask. Link the branch to its specification issue in GitHub when supported, and reference the issue number in the branch name, commits, and pull request. Open each feature pull request against `dev`; include the specification issue and any subtask issue in its description. Use `Refs #<number>` when a pull request must not close an issue. Never commit or push directly to `main`; changes to `main` go through a pull request.

### Issue tracker

Issues and specs are tracked in GitHub Issues. See `docs/agents/issue-tracker.md`.

### Triage labels

Use the default triage vocabulary. See `docs/agents/triage-labels.md`.

### Domain docs

This is a single-context repository. See `docs/agents/domain.md`.

