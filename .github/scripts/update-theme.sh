#!/bin/bash
set -euo pipefail

# Update to latest version
go get -u github.com/LeakIX/hugo-leakix-dark@latest

# Extract version before go mod tidy (which may remove the indirect dependency)
NEW_VERSION=$(grep 'github.com/LeakIX/hugo-leakix-dark' go.mod | awk '{print $3}')

# Check if there were changes
if git diff --quiet go.mod go.sum; then
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "updated=false" >> "$GITHUB_OUTPUT"
  fi
  echo "No updates available"
else
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "updated=true" >> "$GITHUB_OUTPUT"
    echo "new_version=$NEW_VERSION" >> "$GITHUB_OUTPUT"
  fi
  echo "Theme updated to: $NEW_VERSION"
fi
