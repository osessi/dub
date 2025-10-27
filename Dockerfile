# Étape 1 : Builder
FROM node:20 AS builder
WORKDIR /app

# Installer Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# Copier tout le monorepo
COPY . .

# Créer un package.json minimal à la racine si nécessaire
RUN if [ ! -f /app/package.json ]; then \
    echo '{"name":"dub-monorepo","private":true,"workspaces":["apps/*","packages/*"]}' > /app/package.json; \
    fi

# Installer les dépendances du monorepo
RUN bun install

# Installer Prisma globalement pour éviter l'auto-install
RUN bun add -d prisma@6.18.0 @prisma/client@6.18.0

# Fusionner les schémas Prisma
RUN mkdir -p /tmp/prisma && \
    cat /app/packages/prisma/schema/*.prisma | grep -v '^import' > /tmp/prisma/schema.prisma

# Générer le client Prisma avec le bon contexte
RUN cd /app && bunx prisma generate --schema=/tmp/prisma/schema.prisma

# Builder Next.js
WORKDIR /app/apps/web
RUN bun run build

# Étape 2 : Runner
FROM node:20-slim AS runner
WORKDIR /app

# Installer Bun dans le runner
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# Copier les fichiers buildés
COPY --from=builder /app/apps/web/.next ./apps/web/.next
COPY --from=builder /app/apps/web/public ./apps/web/public
COPY --from=builder /app/apps/web/package.json ./apps/web/package.json
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages ./packages

WORKDIR /app/apps/web
EXPOSE 3000

CMD ["bun", "run", "start"]
