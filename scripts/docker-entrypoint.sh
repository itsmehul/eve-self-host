#!/bin/sh
set -eu

# Idempotent Workflow Postgres world schema (graphile-worker + world tables)
if [ -n "${WORKFLOW_POSTGRES_URL:-${DATABASE_URL:-}}" ]; then
  echo "Bootstrapping @workflow/world-postgres schema..."
  pnpm exec bootstrap
fi

exec pnpm exec next start -H 0.0.0.0 -p "${PORT:-3000}"
