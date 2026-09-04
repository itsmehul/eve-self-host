# eve-self-host

Next.js Web Chat + eve agent, configured for self-hosting ([Next.js](https://eve.dev/docs/guides/frontend/nextjs), [Self-hosting](https://eve.dev/docs/guides/deployment/self-hosting)).

Requires **Node.js 24+**.

## Setup

```bash
cp .env.example .env
# set AI_GATEWAY_API_KEY and ROUTE_AUTH_BASIC_PASSWORD (mirror NEXT_PUBLIC_*)
pnpm install
pnpm dev
```

- Dev: `pnpm dev` runs Next + eve via `withEve()` (same-origin `/eve/v1/*`).
- Agent TUI only: `pnpm dev:eve`.

## Self-host production

```bash
pnpm build          # eve build && next build
pnpm start          # Next proxies /eve and /.well-known/workflow to local eve

# Or agent-only Node service:
pnpm build:eve && PORT=3000 pnpm start:eve
```

Docker (Postgres workflow world via `@workflow/world-postgres`):

```bash
cp .env.example .env   # set secrets; compose overrides DB host to `db`
docker compose up --build
# one-shot schema locally (compose entrypoint also runs this):
pnpm workflow:bootstrap
```

Reverse proxy must forward `/eve/` and `/.well-known/workflow/` without path rewrites.

Health check: `curl http://localhost:3000/eve/v1/health`
