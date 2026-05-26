#!/bin/sh
# Entrypoint for OHDSI WebAPI 3.0 (Spring Boot 3.x executable JAR, Java 21).
# Thin replacement for the 2.x docker-entrypoint.sh: keeps Broadsea's Docker-secrets
# pattern but launches the 3.0 JAR via the image's own loader instead of the WarLauncher.
set -e

# Map the Docker secret into the env vars WebAPI 3.0 expects.
# 3.0 uses SPRING_FLYWAY_PASSWORD (not FLYWAY_DATASOURCE_PASSWORD).
export DATASOURCE_PASSWORD="$(cat /run/secrets/WEBAPI_DATASOURCE_PASSWORD)"
export SPRING_FLYWAY_PASSWORD="$DATASOURCE_PASSWORD"
export SECURITY_AUTH_DB_DATASOURCE_PASSWORD="$DATASOURCE_PASSWORD"

# JWT signing secret (HS256). 3.0 binds env SECURITY_JWT_SECRET -> security.jwt.secret
# and fails startup if it is blank. Injected from the Docker secret, not the env file.
export SECURITY_JWT_SECRET="$(cat /run/secrets/SECURITY_JWT_SECRET)"

# Only set a custom trustStore when a non-empty cacerts file is mounted at /tmp/cacerts.
# Otherwise rely on the JRE's default ($JAVA_HOME/lib/security/cacerts) — no hard-coded path.
TRUST_OPT=""
[ -s /tmp/cacerts ] && TRUST_OPT="-Djavax.net.ssl.trustStore=/tmp/cacerts"

cd /var/lib/ohdsi/webapi
exec java ${DEFAULT_JAVA_OPTS} ${JAVA_OPTS} ${TRUST_OPT} \
  -Dloader.path=/opt/webapi/plugins \
  --add-opens java.naming/com.sun.jndi.ldap=ALL-UNNAMED \
  -jar WebAPI.jar
