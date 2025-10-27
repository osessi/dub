# Étape 1 : Build avec Node + Bun
FROM node:20 AS builder

WORKDIR /app
COPY . .

# Installer Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# Installer toutes les dépendances du monorepo
RUN bun install

# ✅ Installer Prisma (et @prisma/client) pour éviter l’auto-installation
RUN npm install prisma @prisma/client --save-dev

# Aller dans l'app principale
WORKDIR /app/apps/web

# Fusionner et nettoyer les schémas Prisma
RUN echo "=== Fusion du schéma Prisma ===" && \
    mkdir -p /tmp/prisma && \
    cat ../../packages/prisma/schema/*.prisma > /tmp/prisma/schema_raw.prisma && \
    grep -v '^import' /tmp/prisma/schema_raw.prisma > /tmp/prisma/schema.prisma && \
    echo "=== Schéma nettoyé ==="

# ✅ Générer le client Prisma sans auto-install
RUN npx prisma generate --schema=/tmp/prisma/schema.prisma && \
    echo "=== Prisma Client généré avec succès ==="

# Build Next.js avec Bun (plus rapide)
RUN bunx next build

# Étape 2 : Image finale légère
FROM node:20-slim AS runner

WORKDIR /app
COPY --from=builder /app /app
WORKDIR /app/apps/web

EXPOSE 3000
CMD ["bunx", "next", "start"]
