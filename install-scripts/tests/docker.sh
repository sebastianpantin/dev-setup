#!/usr/bin/env bash
# Build a fresh Arch image from the current working copy and run the install test.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMAGE=dev-setup-test

docker build -f "$REPO_DIR/install-scripts/tests/Dockerfile" -t "$IMAGE" "$REPO_DIR"
docker run --rm "$IMAGE"
