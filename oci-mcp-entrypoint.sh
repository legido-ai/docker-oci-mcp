#!/bin/sh
set -eu
umask 077

: "${OCI_TENANCY:?missing OCI_TENANCY}"
: "${OCI_USER:?missing OCI_USER}"
: "${OCI_FINGERPRINT:?missing OCI_FINGERPRINT}"
: "${OCI_REGION:?missing OCI_REGION}"
: "${OCI_PRIVATE_KEY_B64:?missing OCI_PRIVATE_KEY_B64}"

dir=$(mktemp -d)
printf '%s' "$OCI_PRIVATE_KEY_B64" | base64 -d > "$dir/key.pem"
test -s "$dir/key.pem"
printf '[OCI_AGENT]\nuser=%s\nfingerprint=%s\nkey_file=%s\ntenancy=%s\nregion=%s\n' \
  "$OCI_USER" "$OCI_FINGERPRINT" "$dir/key.pem" "$OCI_TENANCY" "$OCI_REGION" \
  > "$dir/config"
export OCI_CONFIG_FILE="$dir/config" OCI_CONFIG_PROFILE=OCI_AGENT
export OCI_MCP_AUTH_TYPE=api_key
unset OCI_PRIVATE_KEY_B64

# Force TCP DNS. Some hosts (e.g. Docker-in-Docker with UDP :53 blocked) make
# the glibc resolver fail, so OCI API hostnames never resolve and every call
# hangs. RES_OPTIONS is honoured by glibc and needs no root and no edit to
# /etc/resolv.conf (which is not writable by our non-root user).
case " ${RES_OPTIONS:-} " in
  *" use-vc "*) ;;
  *) RES_OPTIONS="${RES_OPTIONS:+${RES_OPTIONS} }use-vc" ;;
esac
export RES_OPTIONS

exec /opt/oci-mcp/bin/oracle.oci-cloud-mcp-server
