#!/bin/bash
set -euo pipefail

# Get latest commit from GitHub API
LATEST=$(curl -s https://api.github.com/repos/LeakIX/hugo-leakix-dark/commits/main | jq -r '.sha[:12]')
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "latest=$LATEST" >> "$GITHUB_OUTPUT"
fi
echo "Latest commit: $LATEST"
