# ----------- BUILDER -----------
FROM node:18-alpine AS builder

WORKDIR /app
COPY . .

# Installer PNPM
RUN npm install -g pnpm

# Installer toutes les dépendances du monorepo (pas seulement apps/web)
RUN pnpm install --no-frozen-lockfile

# Générer Prisma (important pour Dub)
RUN pnpm --filter=@dub/prisma generate || true

# Construire le front Next.js
WORKDIR /app/apps/web
RUN pnpm run build

# ----------- RUNNER -----------
FROM node:18-alpine AS runner

WORKDIR /app

# Copier le build depuis l'image builder
COPY --from=builder /app/apps/web ./

# Installer PNPM dans l'image finale
RUN npm install -g pnpm

# Exposer le port de Next.js
EXPOSE 3000

# Lancer l'app
CMD ["pnpm", "start"]
