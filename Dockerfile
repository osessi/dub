FROM node:18-alpine AS builder
WORKDIR /app

# Copier les fichiers essentiels pour installer
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY packages ./packages
COPY apps ./apps

RUN npm install -g pnpm
RUN pnpm install --no-frozen-lockfile

# Générer Prisma ou autre lib build
RUN pnpm --filter=@dub/prisma generate || true

WORKDIR /app/apps/web
RUN pnpm run build

FROM node:18-alpine AS runner
WORKDIR /app
COPY --from=builder /app/apps/web ./
ENV NODE_ENV=production
EXPOSE 3000
CMD ["pnpm", "start"]
