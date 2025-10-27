# Étape 1 : Build avec Node + Bun
FROM node:20 AS builder

WORKDIR /app
COPY . .

# Installer Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# Installer toutes les dépendances (le monorepo a un package.json à la racine)
RUN bun install

# Aller dans le projet principal
WORKDIR /app/apps/web

# Fusionner et nettoyer les schémas Prisma
RUN echo "=== Fusion du schéma Prisma ===" && \
    mkdir -p /tmp/prisma && \
    cat ../../packages/prisma/schema/*.prisma > /tmp/prisma/schema_raw.prisma && \
    grep -v '^import' /tmp/prisma/schema_raw.prisma > /tmp/prisma/schema.prisma && \
    echo "=== Schéma nettoyé ==="

# 👉 Ici, on force Prisma à utiliser la racine du monorepo comme project root
RUN bunx --cwd /app prisma generate --schema=/tmp/prisma/schema.prisma && \
    echo "=== Prisma Client généré ==="

# Build Next.js
RUN bunx next build

# Étape 2 : Image finale légère
FROM node:20-slim AS runner

WORKDIR /app
COPY --from=builder /app /app
WORKDIR /app/apps/web

EXPOSE 3000
CMD ["bunx", "next", "start"]
