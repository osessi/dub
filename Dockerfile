# Étape 1 : Build avec Node (pour Prisma)
FROM node:20 AS builder

WORKDIR /app
COPY . .

# Installer Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# Installer les dépendances avec Bun
RUN bun install

# Aller dans l'app principale
WORKDIR /app/apps/web

# Fusionner et nettoyer le schéma Prisma
RUN echo "=== Fusion du schéma Prisma ===" && \
    mkdir -p /tmp/prisma && \
    cat ../../packages/prisma/schema/*.prisma > /tmp/prisma/schema_raw.prisma && \
    grep -v '^import' /tmp/prisma/schema_raw.prisma > /tmp/prisma/schema.prisma && \
    bunx prisma generate --schema=/tmp/prisma/schema.prisma

# Construire Next.js
RUN bunx next build

# Étape 2 : Image finale (plus légère)
FROM node:20-slim AS runner

WORKDIR /app
COPY --from=builder /app /app
WORKDIR /app/apps/web

EXPOSE 3000
CMD ["bunx", "next", "start"]
