#!/usr/bin/env bash
# Build the test image and run the tests against the current working copy.
# Usage: tests/docker.sh [run.sh arguments]   (default: --all)
set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE=nvim-config-test

docker build -f "$CONFIG_DIR/tests/Dockerfile" -t "$IMAGE" "$CONFIG_DIR"
docker run --rm -v "$CONFIG_DIR:/config:ro" "$IMAGE" tests/run.sh "${@:---all}"
