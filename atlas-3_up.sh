#!/usr/bin/env bash
# Bring up the Atlas/WebAPI 3.0 stack (atlasdb + webapi-3 + atlas-3; traefik is
# profile-less and always included). Run from anywhere — cd's to the repo root.
set -euo pipefail

cd "$(dirname "$0")"

docker compose \
  --profile atlasdb \
  --profile webapi-3 \
  --profile atlas-3 \
  up -d "$@"
