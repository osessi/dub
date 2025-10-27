# ----------- BUILDER -----------
FROM node:18-alpine AS builder

WORKDIR /app
COPY . .

# Installer pnpm
RUN npm install -g pnpm

# Installer toutes les dépendances du monorepo
RUN pnpm install --no-frozen-lockfile

# Générer les fichiers Prisma (Dub les utilise)
RUN pnpm --filter=@dub/prisma generate || true

# Construire le frontend Next.js
RUN cd apps/web && pnpm run build

# ----------- RUNNER -----------
FROM node:18-alpine
WORKDIR /app

# Copier seulement le build nécessaire
COPY --from=builder /app/apps/web ./

# Installer pnpm à nouveau
RUN npm install -g pnpm

# Exposer le port 3000
EXPOSE 3000

# Lancer le serveur Next.js
CMD ["pnpm", "start"]
