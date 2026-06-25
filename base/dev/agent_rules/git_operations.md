# Git Operations

Agents should treat git as read-only unless the user explicitly requests a mutation such as staging, committing, or pushing.

## Rules

- Read-only git is fine: `status`, `diff`, `log`, `show`, `ls-files`, `cat-file`, `check-ignore`.
- Do not run `git add`, `commit`, `restore`, `reset`, `stash`, `checkout`, `rm`, or `mv` unless explicitly requested.
- When work is done, at most suggest a commit message if asked. The user stages and commits themselves by default.
- Never retry a failed git mutation "one more way". Stop at the first failure and hand off to the user.
