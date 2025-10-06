#!/bin/bash
set -euo pipefail

# Get current theme version from go.mod
CURRENT=$(grep 'github.com/LeakIX/hugo-leakix-dark' go.mod | awk '{print $2}')
echo "version=$CURRENT" >> "${GITHUB_OUTPUT:-/dev/stdout}"
echo "Current theme version: $CURRENT"
