# Command: commit-to-git

## Description

Commit the current project state to git and push to a private GitHub repository, with optional cloud deployment.

The Cursor version of this command uses `./cursor/scripts/commit-to-git.sh` and:

- TTY-aware interactive prompts when run in an interactive terminal.
- Safe handling of GitHub CLI installation and authentication.
- Automatic creation of a private GitHub repo when no `origin` remote exists.
- Consistent branch selection, staging, commit, and push behavior.
- Optional cloud deployment controlled by environment variables.

Other tools (Claude, VS Code) have their own `commit-to-git` scripts under their respective `scripts/` directories that implement the same behavior so each tooling directory can be copied and used independently.

## Run

- **Script**: `./.cursor/scripts/commit-to-git.sh`
- **Working directory**: project root (`${workspaceFolder}`)

## Tags

- git
- github
- deploy
- cloud




