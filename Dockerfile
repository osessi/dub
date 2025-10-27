# Étape 1 : Build avec Bun
FROM oven/bun:1.1.21 AS builder

WORKDIR /app
COPY . .

# Installer toutes les dépendances du monorepo
RUN bun install

# Aller dans le projet web principal
WORKDIR /app/apps/web

# Générer Prisma + construire Next.js
RUN bunx prisma generate --schema=../../packages/prisma/schema/schema.prisma && bunx next build

# Étape 2 : Image finale plus légère
FROM oven/bun:1.1.21 AS runner
WORKDIR /app

# Copier le code compilé
COPY --from=builder /app .

# Aller dans l'app principale
WORKDIR /app/apps/web

# Exposer le port utilisé par Next.js
EXPOSE 3000

# Lancer le serveur Next.js
CMD ["bunx", "next", "start"]
