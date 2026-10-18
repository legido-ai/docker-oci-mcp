# docker-oci-mcp

Container image for the Oracle **OCI Cloud MCP server** (`oracle.oci-cloud-mcp-server`)
used by `docker-opencode` as the `oci_cloud` MCP server. It runs over **stdio**.

- Image: `oracle-oci-cloud-mcp:2.2.3` (CI publishes `ghcr.io/legido-ai/docker-oci-mcp`)
- Base: `python:3.13-slim`
- Pinned app version: `oracle.oci-cloud-mcp-server==2.2.3` (installed into `/opt/oci-mcp`)
- Runs as **non-root** user `10001:10001`
- Transport: stdio (`docker run -i`)

## Files

| File | Purpose |
|---|---|
| `Dockerfile.oci-mcp` | Image definition. |
| `oci-mcp-entrypoint.sh` | Entrypoint; decodes the API key, writes a temporary OCI config, execs the server. |
| `build.sh` | Explicit build script; refuses to build outside the intended DinD daemon. |
| `.env.example` | Required variable **names** only. |

## Required credentials

Set these five variables (names only here; never commit values):

- `OCI_TENANCY` — tenancy OCID
- `OCI_USER` — user OCID
- `OCI_FINGERPRINT` — API key fingerprint
- `OCI_REGION` — region identifier (e.g. `eu-frankfurt-1`)
- `OCI_PRIVATE_KEY_B64` — base64 of the PEM API private key

At startup the entrypoint fails fast if any is unset, base64-decodes
`OCI_PRIVATE_KEY_B64` into a `0600` file inside a fresh `mktemp -d`, writes an
`OCI_AGENT` profile config pointing at it, exports `OCI_CONFIG_FILE`,
`OCI_CONFIG_PROFILE=OCI_AGENT`, `OCI_MCP_AUTH_TYPE=api_key`, unsets the key
variable, and `exec`s the server.

## Build

The image must be built **in the same Docker daemon that OpenCode uses** (the
DinD daemon at `unix:///dind/docker.sock` in this environment); a child container
launched by OpenCode resolves `oracle-oci-cloud-mcp:2.2.3` against that daemon.

```sh
./build.sh                       # builds oracle-oci-cloud-mcp:2.2.3
./build.sh oracle-oci-cloud-mcp:dev
```

`build.sh` prints the active daemon and refuses to build unless it equals
`EXPECTED_DOCKER_HOST` (default `unix:///dind/docker.sock`). It never silently
switches daemon; override deliberately with `ALLOW_ANY_DAEMON=1`.

Manual equivalent:

```sh
DOCKER_HOST=unix:///dind/docker.sock \
docker build -f Dockerfile.oci-mcp -t oracle-oci-cloud-mcp:2.2.3 .
```

## Run (stdio)

```sh
docker run -i --rm \
  --cap-drop=ALL --security-opt=no-new-privileges \
  -e OCI_TENANCY -e OCI_USER -e OCI_FINGERPRINT -e OCI_REGION -e OCI_PRIVATE_KEY_B64 \
  oracle-oci-cloud-mcp:2.2.3
```

## Security limitations

- **Tenancy-wide credentials.** The OCI identity behind these credentials has
  tenancy-wide management permissions; any caller that can reach the server can
  create, update, or delete cloud resources.
- **No built-in authorization.** The server trusts its caller; isolation is
  provided by OpenCode/agent permissions, not this image.
- **Secrets are in the process environment.** Anyone able to `docker inspect`
  the running container can read the passed variables; the key file is transient
  inside the container (mode 0600, `umask 077`).
- **No secret material is baked into the image or committed.** Do not add `.env`,
  OCI config files, private keys, tokens, or workspace data to the build context.
- Not hardened beyond non-root execution and the runtime flags above; base image
  CVEs apply.
