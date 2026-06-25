Close out completed work: update CHANGELOG, TODO, archive plan/spec files, and suggest running `/commit-msg` for the final commit message.

This command never stages, commits, pushes, creates PRs, or invokes `/pr-review`. It is a documentation cleanup workflow only.

## Detect mode

Run `git status` and `git branch --show-current`:

- Staged mode — there are staged changes: the completed scope is the staged diff.
- Branch mode — no staged changes, and the current branch is not `main` and is ahead of it: the completed scope is `git diff main...HEAD`.
- Neither applies → ask what to close out.

## Steps

1. Identify the plan/spec file(s) in the completed scope under `dev/docs/plans/`. If none is found, ask which plan file(s) to use.
2. Read each plan file to understand the completed scope and phases.
3. Append a CHANGELOG entry per plan under `CHANGELOG.md`, following the rules in the file header and any change-summary standard in the project.
4. Remove each plan's one-line pointer from `TODO.md` `## Active` or `## Plan`. If `## Active` becomes empty, replace it with the project's empty-state wording.
5. Move each plan file and its sibling spec/scout files from `dev/docs/plans/` to `dev/docs/archived/`.
6. Run `git status` to show the final state.
7. Suggest running `/commit-msg` to generate a commit message for the completed scope.
