#!/bin/bash
set -euo pipefail

# Get current theme version from go.mod
CURRENT=$(grep 'github.com/LeakIX/hugo-leakix-dark' go.mod | awk '{print $3}')
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$CURRENT" >> "$GITHUB_OUTPUT"
fi
echo "Current theme version: $CURRENT"
