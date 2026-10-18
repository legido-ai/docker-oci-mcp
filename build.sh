#!/usr/bin/env bash
# Build the OCI Cloud MCP image in the Docker daemon used by OpenCode (DinD).
#
# This script does NOT silently fall back to any other daemon. It builds in
# whatever daemon the ambient `DOCKER_HOST` / active docker context points at,
# prints that daemon, and refuses to continue if it is not the expected DinD
# daemon unless ALLOW_ANY_DAEMON=1 is set explicitly.
#
# Usage:
#   ./build.sh [IMAGE_TAG]           # default: oracle-oci-cloud-mcp:2.2.3
#
# Env overrides:
#   IMAGE                  image tag to produce (default oracle-oci-cloud-mcp:2.2.3)
#   EXPECTED_DOCKER_HOST   required daemon (default unix:///dind/docker.sock)
#   ALLOW_ANY_DAEMON=1     allow building in a daemon other than EXPECTED_DOCKER_HOST
set -euo pipefail

cd "$(cd -- "$(dirname -- "$0")" && pwd)"

IMAGE="${1:-${IMAGE:-oracle-oci-cloud-mcp:2.2.3}}"
EXPECTED_HOST="${EXPECTED_DOCKER_HOST:-unix:///dind/docker.sock}"

active_host="${DOCKER_HOST:-}"
if [ -z "${active_host}" ]; then
  active_host="$(docker context inspect --format '{{.Endpoints.docker.Host}}' 2>/dev/null || true)"
fi

echo "image:       ${IMAGE}"
echo "daemon host: ${active_host:-<unknown>}"
echo "expected:    ${EXPECTED_HOST}"

if [ "${active_host}" != "${EXPECTED_HOST}" ]; then
  echo "WARNING: active Docker daemon is not the expected DinD daemon." >&2
  if [ "${ALLOW_ANY_DAEMON:-0}" != "1" ]; then
    echo "Refusing to build. Re-run with ALLOW_ANY_DAEMON=1 to override." >&2
    exit 2
  fi
  echo "ALLOW_ANY_DAEMON=1 set; continuing in ${active_host:-<unknown>}." >&2
fi

docker build \
  --file Dockerfile.oci-mcp \
  --tag "${IMAGE}" \
  .

echo "Built ${IMAGE} in ${active_host:-<unknown>}"
