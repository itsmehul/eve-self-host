#!/bin/sh
set -eu

# Idempotent Workflow Postgres world schema (graphile-worker + world tables)
if [ -n "${WORKFLOW_POSTGRES_URL:-${DATABASE_URL:-}}" ]; then
  echo "Bootstrapping @workflow/world-postgres schema..."
  pnpm exec bootstrap
fi

EVE_PORT="${EVE_NEXT_PRODUCTION_PORT:-4274}"
EVE_SERVER=".output/server/index.mjs"

if [ ! -f "$EVE_SERVER" ]; then
  echo "Missing $EVE_SERVER — run eve build before starting." >&2
  exit 1
fi

# withEve rewrites /eve and /.well-known/workflow to 127.0.0.1:$EVE_PORT.
# next start does not reliably spawn that Nitro process in Docker, so start it here.
echo "Starting eve runtime on 127.0.0.1:${EVE_PORT}..."
HOST=127.0.0.1 \
  NITRO_HOST=127.0.0.1 \
  NITRO_PORT="${EVE_PORT}" \
  PORT="${EVE_PORT}" \
  node "$EVE_SERVER" &
EVE_PID=$!

cleanup() {
  kill "$EVE_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

i=0
while [ "$i" -lt 60 ]; do
  if node -e "const n=require('net');const s=n.connect({host:'127.0.0.1',port:${EVE_PORT}},()=>{s.end();process.exit(0)});s.on('error',()=>process.exit(1))"; then
    break
  fi
  if ! kill -0 "$EVE_PID" 2>/dev/null; then
    echo "eve runtime exited before becoming ready." >&2
    exit 1
  fi
  i=$((i + 1))
  sleep 0.5
done

if [ "$i" -ge 60 ]; then
  echo "Timed out waiting for eve on 127.0.0.1:${EVE_PORT}." >&2
  exit 1
fi

exec pnpm exec next start -H 0.0.0.0 -p "${PORT:-3000}"
