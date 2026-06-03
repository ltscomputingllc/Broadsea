# OHDSI Atlas3 (Vue3 + Vuetify + Vite SPA) — built the Broadsea way: a locally-built
# image served by Caddy as a static file-server on :8080 behind Traefik.
#
# The build stage mirrors the upstream OHDSI/Atlas3 Dockerfile; the only change is that
# the source is pulled by a SHA-pinned `git fetch` (Broadsea's build context is ./atlas-3,
# not the Atlas3 repo). The serve stage is upstream's Caddy stage reduced to a file server
# on :8080 — Traefik owns TLS and the /WebAPI route, so the upstream TLS + /WebAPI proxy
# are dropped (see ./Caddyfile).

# --- build stage: identical to OHDSI/Atlas3 Dockerfile (source via pinned SHA) ---
FROM node:20-alpine AS build
ARG ATLAS3_REPO=https://github.com/OHDSI/Atlas3.git
ARG ATLAS3_REF=cknoll/structure-changes
# ATLAS3_SHA (when set) is the pinned commit AND the Docker cache key — bump it to redeploy a
# newer commit. Leave ATLAS3_SHA EMPTY to instead fetch the ATLAS3_REF branch tip; only then does
# `docker build --no-cache` actually take the latest tip (a non-empty SHA always pins that commit).
ARG ATLAS3_SHA=f80f7169c92dd3a7ec5b86a9e0ff67dbb1472502
RUN apk add --no-cache git
WORKDIR /app
# SHA wins when provided; falls back to the ATLAS3_REF branch tip when SHA is empty.
RUN git init -q && git remote add origin "${ATLAS3_REPO}" \
    && git fetch --depth 1 origin "${ATLAS3_SHA:-$ATLAS3_REF}" && git checkout -q FETCH_HEAD
ARG VITE_BASE_PATH=/atlas/
ARG VITE_AUTH_ENABLED=true
ARG VITE_AUTH_SKIP_LOGIN=false
ARG VITE_AUTH_PROVIDERS='[{"name":"Database","url":"user/login/db","ajax":true,"icon":"mdi-database","isUseCredentialsForm":true}]'
ARG VITE_BAO_AGENT_ENABLED=false
ENV VITE_BASE_PATH=${VITE_BASE_PATH} \
    VITE_AUTH_ENABLED=${VITE_AUTH_ENABLED} \
    VITE_AUTH_SKIP_LOGIN=${VITE_AUTH_SKIP_LOGIN} \
    VITE_AUTH_PROVIDERS=${VITE_AUTH_PROVIDERS} \
    VITE_BAO_AGENT_ENABLED=${VITE_BAO_AGENT_ENABLED}
RUN npm ci && npm run build

# --- serve stage: upstream's Caddy stage, file-server only, on 8080 ---
FROM caddy:2-alpine
COPY --from=build /app/dist /srv/atlas
COPY Caddyfile /etc/caddy/Caddyfile
# Broadsea default runtime config (relative /WebAPI, DB-auth). Overridable per-host via a
# bind-mount onto /srv/atlas/config-local.json (see compose/ohdsi-atlas-3.yml) — no rebuild needed.
COPY config-local.json /srv/atlas/config-local.json
EXPOSE 8080
