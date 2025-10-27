# Étape 1 : utiliser Bun (plus rapide et plus stable que PNPM)
FROM oven/bun:1.1.21 AS builder

# Définir le répertoire de travail
WORKDIR /app

# Copier tous les fichiers du projet
COPY . .

# Installer les dépendances
RUN bun install

# Construire toutes les apps/packages via Turbo
RUN bun run build

# Étape 2 : image finale plus légère
FROM oven/bun:1.1.21 AS runner
WORKDIR /app

# Copier uniquement le nécessaire depuis l'étape précédente
COPY --from=builder /app .

# Définir la variable d'environnement
ENV NODE_ENV=production

# Exposer le port par défaut (Next.js écoute sur 3000)
EXPOSE 3000

# Aller dans l'app principale (apps/web)
WORKDIR /app/apps/web

# Lancer l'application en production
CMD ["bun", "run", "start"]
