Suggest a conventional commit message for the currently staged changes.

This command never stages, commits, pushes, creates PRs, or mutates git state. It only reads the staged diff and writes a suggested commit message.

## Detect scope

Run read-only git commands only:

- `git diff --cached --name-status`
- `git diff --cached --stat`
- `git diff --cached`

If there are no staged changes, stop and say there is nothing staged to summarize. Do not inspect unstaged changes unless the user explicitly asks.

## Steps

1. Read `dev/standards/change_summary_standard.md` if present, then read the staged file list and staged diff.
2. Infer the most appropriate conventional commit type and optional scope from the staged changes.
3. Write one recommended commit message in conventional commit format:

```text
type(scope): concise summary

- Bullet summarizing the first logical change
- Bullet summarizing the second logical change
```

4. Keep the body to 2-3 bullets unless the staged diff is truly tiny, in which case a subject line alone is fine.
5. Do not hard-wrap prose. Describe what changed in the codebase or durable project rules, not what command was run.
6. If the staged changes represent multiple unrelated commits, say so and suggest a split, then provide the best single-message fallback only if the user still wants one.
