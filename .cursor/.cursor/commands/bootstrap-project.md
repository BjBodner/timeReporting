# Command: bootstrap-project

## Description

Copy the user's Cursor tooling directory (`~/.cursor`) into the current project as `.cursor`, so the project has a self-contained set of Cursor rules and scripts that can be copied or reused independently.

**Note**: This command assumes the current working directory is the project root. It creates and populates `[project-root]/.cursor/` only; it does not create any `cursor/` directory.

Behavior (Cursor context):

- Detect `~/.cursor` as the source and `.cursor` in the project root as the destination.
- Recursively copy files, creating missing directories as needed.
- In interactive mode, prompt on conflicts (whether to overwrite existing files).
- In non-interactive mode, abort on conflicts with a clear error.
- Print a summary of copied/skipped files and final status.

## Run

- **Script**: `./.cursor/scripts/bootstrap-project.sh`
- **Working directory**: project root (`${workspaceFolder}`)

## Tags

- bootstrap
- rules
- cursor



