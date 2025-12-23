#!/usr/bin/env bash

# Cursor script: bootstrap-project
# Copy the user's Cursor tooling directory (~/.cursor) into the project
# as .cursor, so the project has a self-contained set of rules/scripts.
#
# Self-contained implementation to copy ~/.cursor into ./.cursor (rules/scripts)
# for bootstrapping a project.

set -euo pipefail

echo "[Cursor] Running bootstrap-project (assuming current directory is project root)"

GLOBAL_SCRIPT_DIR="$HOME/.cursor/scripts"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# If running from the global toolkit and the project does not yet have a
# project-local bootstrap-project script, install it and re-exec from there
if [ "$SCRIPT_DIR" = "$GLOBAL_SCRIPT_DIR" ] && [ ! -f ".cursor/scripts/$SCRIPT_NAME" ]; then
  echo "[bootstrap-project] Installing project-local .cursor/scripts/$SCRIPT_NAME from global toolkit"
  mkdir -p .cursor/scripts
  cp "$SCRIPT_DIR/$SCRIPT_NAME" ".cursor/scripts/$SCRIPT_NAME"
  chmod +x ".cursor/scripts/$SCRIPT_NAME" || true
  exec ".cursor/scripts/$SCRIPT_NAME" "$@"
fi

main() {
  echo "[bootstrap-project] Starting..."

  phase_detect_and_validate
  phase_copy_with_conflicts
  phase_summary

  echo "[bootstrap-project] Done."
}

SRC_DIR=""
DEST_DIR=""
COPIED_COUNT=0
SKIPPED_COUNT=0
ABORT_REASON=""

phase_detect_and_validate() {
  echo "[phase 1] Detect environment & resolve paths"

  SRC_DIR="$HOME/.cursor"
  DEST_DIR=".cursor"

  echo "  - Source: $SRC_DIR"
  echo "  - Destination: $DEST_DIR"

  if [ ! -d "$SRC_DIR" ]; then
    echo "  - No tooling directory found at $SRC_DIR"
    ABORT_REASON="source-missing"
    exit 1
  fi
}

copy_subtree() {
  local src_root="$1"
  local dest_root="$2"

  if [ ! -d "$src_root" ]; then
    return 0
  fi

  while IFS= read -r -d '' src_path; do
    local rel_path="${src_path#$src_root/}"
    local dest_path="$dest_root/$rel_path"
    local dest_dir
    dest_dir="$(dirname "$dest_path")"

    if [ ! -d "$dest_dir" ]; then
      mkdir -p "$dest_dir"
    fi

    if [ ! -e "$dest_path" ]; then
      cp "$src_path" "$dest_path"
      COPIED_COUNT=$((COPIED_COUNT + 1))
    else
      handle_conflict "$src_path" "$dest_path" || return 1
    fi
  done < <(find "$src_root" -type f -print0)
}

phase_copy_with_conflicts() {
  echo "[phase 2] Copy rules & scripts with conflict handling"

  # Ensure destination base exists
  mkdir -p "$DEST_DIR"

  # Only copy the subsets of ~/.cursor that projects should carry
  copy_subtree "$SRC_DIR/commands" "$DEST_DIR/commands" || return 1
  copy_subtree "$SRC_DIR/scripts"  "$DEST_DIR/scripts"  || return 1
  copy_subtree "$SRC_DIR/rules"    "$DEST_DIR/rules"    || return 1
}

handle_conflict() {
  local src_path="$1"
  local dest_path="$2"

  if [ -t 0 ]; then
    echo "  - Conflict: $dest_path already exists."
    read -r -p "    Overwrite with version from $SRC_DIR? [y/N]: " answer
    answer="${answer:-N}"
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      cp "$src_path" "$dest_path"
      COPIED_COUNT=$((COPIED_COUNT + 1))
    else
      echo "    Skipping $dest_path"
      SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    fi
  else
    echo "  - Conflict detected in non-interactive mode at: $dest_path"
    echo "    Re-run interactively or resolve manually, then re-run."
    ABORT_REASON="conflict-noninteractive"
    return 1
  fi
}

phase_summary() {
  echo "[phase 3] Summary"
  echo "  - Context: cursor"
  echo "  - Source: $SRC_DIR"
  echo "  - Destination: $DEST_DIR"
  echo "  - Files copied: $COPIED_COUNT"
  echo "  - Files skipped: $SKIPPED_COUNT"

  if [ -n "$ABORT_REASON" ]; then
    echo "  - Status: Aborted ($ABORT_REASON)"
  else
    echo "  - Status: Success"
  fi
}

main "$@"



