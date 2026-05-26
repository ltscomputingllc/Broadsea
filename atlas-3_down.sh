#!/usr/bin/env bash
# Tear down the Atlas/WebAPI 3.0 stack. The profiles MUST match atlas-3_up.sh:
# a bare `docker compose down` (no profiles) can leave the profiled containers
# (atlasdb/webapi-3/atlas-3) running and block network removal, so pass the same
# profiles used to bring them up. Named volumes are kept (no -v), so
# broadsea-atlasdb data persists across down/up.
set -euo pipefail

cd "$(dirname "$0")"

docker compose \
  --profile atlasdb \
  --profile webapi-3 \
  --profile atlas-3 \
  down "$@"
