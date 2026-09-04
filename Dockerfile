# Self-hosted Next.js + eve (withEve co-located topology)
# Docs: https://eve.dev/docs/guides/frontend/nextjs
#       https://eve.dev/docs/guides/deployment/self-hosting
FROM node:24-bookworm-slim AS deps
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

FROM node:24-bookworm-slim AS builder
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ARG AI_GATEWAY_API_KEY
ARG ROUTE_AUTH_BASIC_USERNAME=eve
ARG ROUTE_AUTH_BASIC_PASSWORD
ARG NEXT_PUBLIC_ROUTE_AUTH_BASIC_USERNAME=eve
ARG NEXT_PUBLIC_ROUTE_AUTH_BASIC_PASSWORD
ENV AI_GATEWAY_API_KEY=$AI_GATEWAY_API_KEY \
    ROUTE_AUTH_BASIC_USERNAME=$ROUTE_AUTH_BASIC_USERNAME \
    ROUTE_AUTH_BASIC_PASSWORD=$ROUTE_AUTH_BASIC_PASSWORD \
    NEXT_PUBLIC_ROUTE_AUTH_BASIC_USERNAME=$NEXT_PUBLIC_ROUTE_AUTH_BASIC_USERNAME \
    NEXT_PUBLIC_ROUTE_AUTH_BASIC_PASSWORD=$NEXT_PUBLIC_ROUTE_AUTH_BASIC_PASSWORD
RUN pnpm exec eve build && pnpm exec next build

FROM node:24-bookworm-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME=0.0.0.0
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY --from=builder /app/package.json ./
COPY --from=builder /app/pnpm-lock.yaml ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/.output ./.output
COPY --from=builder /app/.eve ./.eve
COPY --from=builder /app/agent ./agent
COPY --from=builder /app/app ./app
COPY --from=builder /app/components ./components
COPY --from=builder /app/lib ./lib
COPY --from=builder /app/next.config.ts ./
COPY --from=builder /app/tsconfig.json ./
COPY --from=builder /app/scripts ./scripts
RUN chmod +x ./scripts/docker-entrypoint.sh
EXPOSE 3000
ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
