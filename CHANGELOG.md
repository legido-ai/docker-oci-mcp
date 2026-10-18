# Changelog

## [Unreleased]

- Generated from `legido-ai/github-repo-template`.
- Initial OCI Cloud MCP image: `Dockerfile.oci-mcp` (python:3.13-slim,
  `oracle.oci-cloud-mcp-server==2.2.3`, non-root `10001:10001`, stdio),
  `oci-mcp-entrypoint.sh`, `build.sh`, `.env.example` (names only).
- Fix: force TCP DNS in `oci-mcp-entrypoint.sh` by exporting
  `RES_OPTIONS=use-vc`. On hosts where UDP DNS (:53) is blocked, the container's
  glibc resolver fails, so OCI API hostnames never resolve and every
  `invoke_oci_api` call hangs/times out. `RES_OPTIONS` is honoured by glibc and
  needs no root and no edit to the read-only `/etc/resolv.conf`.
