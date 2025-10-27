# ===============================
# Étape 1 : Build avec Bun
# ===============================
FROM oven/bun:1.1.21 AS builder

WORKDIR /app
COPY . .

# Installer toutes les dépendances
RUN bun install

# Aller dans l'app principale
WORKDIR /app/apps/web

# Fusionner tous les fichiers Prisma avant génération
RUN echo "=== Fusion du schéma Prisma ===" && \
    mkdir -p /tmp/prisma && \
    cat ../../packages/prisma/schema/*.prisma > /tmp/prisma/schema.prisma && \
    echo "=== Schéma fusionné ===" && head -n 20 /tmp/prisma/schema.prisma && \
    bunx prisma generate --schema=/tmp/prisma/schema.prisma && \
    echo "=== Prisma Client généré ==="

# Construire Next.js
RUN bunx next build

# ===============================
# Étape 2 : Image finale légère
# ===============================
FROM oven/bun:1.1.21 AS runner
WORKDIR /app

COPY --from=builder /app /app
WORKDIR /app/apps/web

EXPOSE 3000
CMD ["bunx", "next", "start"]
