# Étape 1 : Build avec Bun
FROM oven/bun:1.1.21 AS builder

WORKDIR /app
COPY . .

RUN bun install

WORKDIR /app/apps/web

# Fusionner tous les fichiers Prisma en un seul fichier propre sans les imports
RUN echo "=== Fusion du schéma Prisma ===" && \
    mkdir -p /tmp/prisma && \
    cat ../../packages/prisma/schema/*.prisma > /tmp/prisma/schema_raw.prisma && \
    grep -v '^import' /tmp/prisma/schema_raw.prisma > /tmp/prisma/schema.prisma && \
    echo "=== Schéma nettoyé ===" && \
    head -n 20 /tmp/prisma/schema.prisma && \
    bunx prisma generate --schema=/tmp/prisma/schema.prisma && \
    echo "=== Prisma Client généré ==="

RUN bunx next build

# Étape 2 : Image finale
FROM oven/bun:1.1.21 AS runner
WORKDIR /app
COPY --from=builder /app /app
WORKDIR /app/apps/web

EXPOSE 3000
CMD ["bunx", "next", "start"]
