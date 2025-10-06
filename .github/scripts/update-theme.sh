#!/bin/bash
set -euo pipefail

# Update to latest version
go get -u github.com/LeakIX/hugo-leakix-dark@latest
go mod tidy

# Check if there were changes
if git diff --quiet go.mod go.sum; then
  echo "updated=false" >> "${GITHUB_OUTPUT:-/dev/stdout}"
  echo "No updates available"
else
  echo "updated=true" >> "${GITHUB_OUTPUT:-/dev/stdout}"
  NEW_VERSION=$(grep 'github.com/LeakIX/hugo-leakix-dark' go.mod | awk '{print $2}')
  echo "new_version=$NEW_VERSION" >> "${GITHUB_OUTPUT:-/dev/stdout}"
  echo "Theme updated to: $NEW_VERSION"
fi
