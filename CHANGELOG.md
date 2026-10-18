# Changelog

## [Unreleased]

- Generated from `legido-ai/github-repo-template`.
- Initial OCI Cloud MCP image: `Dockerfile.oci-mcp` (python:3.13-slim,
  `oracle.oci-cloud-mcp-server==2.2.3`, non-root `10001:10001`, stdio),
  `oci-mcp-entrypoint.sh`, `build.sh`, `.env.example` (names only).
- Revert: removed the `RES_OPTIONS=use-vc` TCP-DNS workaround from
  `oci-mcp-entrypoint.sh` (and the README DNS note). It was only needed while the
  host's outbound UDP DNS was broken; that has been fixed, so the entrypoint is
  back to its original form.
