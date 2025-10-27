# Étape 1 : utiliser Bun pour builder plus vite
FROM oven/bun:1.1.21 AS builder

WORKDIR /app

# Copier le contenu du projet
COPY . .

# Installer les dépendances
RUN bun install

# Aller directement dans l'app principale
WORKDIR /app/apps/web

# Construire l'application Next.js
RUN bun run build

# Étape 2 : image finale (plus légère)
FROM oven/bun:1.1.21 AS runner
WORKDIR /app

# Copier le code de l'étape précédente
COPY --from=builder /app .

# Exposer le port
EXPOSE 3000

# Aller dans l'app principale
WORKDIR /app/apps/web

# Lancer le serveur
CMD ["bun", "run", "start"]
