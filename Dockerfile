# Étape 1 : Build avec Node + Bun
FROM node:20 AS builder
WORKDIR /app

# Installer Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# Copier les fichiers
COPY . .

# Installer les dépendances avec Bun (qui gère mieux le monorepo)
RUN bun install

# Aller dans l'app web
WORKDIR /app/apps/web

# Fusionner les schémas Prisma (sans les imports)
RUN mkdir -p /tmp/prisma && \
    cat ../../packages/prisma/schema/*.prisma | grep -v '^import' > /tmp/prisma/schema.prisma

# Générer le client Prisma
RUN bun x prisma generate --schema=/tmp/prisma/schema.prisma

# Build Next.js
RUN bun run build

# Étape 2 : Image finale
FROM node:20-slim AS runner
WORKDIR /app

# Copier les fichiers nécessaires
COPY --from=builder /app/apps/web/.next ./apps/web/.next
COPY --from=builder /app/apps/web/public ./apps/web/public
COPY --from=builder /app/apps/web/package.json ./apps/web/package.json
COPY --from=builder /app/node_modules ./node_modules

WORKDIR /app/apps/web
EXPOSE 3000

CMD ["node_modules/.bin/next", "start"]
