# ===============================
# Étape 1 : Build avec Bun
# ===============================
FROM oven/bun:1.1.21 AS builder

# Définir le dossier de travail principal
WORKDIR /app

# Copier tous les fichiers du projet
COPY . .

# Installer toutes les dépendances du monorepo
RUN bun install

# Aller dans l'app principale
WORKDIR /app/apps/web

# Générer le client Prisma avec le bon schéma
RUN echo "=== Vérification du schéma Prisma ===" && \
    ls -al ../../packages/prisma/schema && \
    bunx prisma generate --schema=../../packages/prisma/schema/schema.prisma && \
    echo "=== Prisma Client généré avec succès ==="

# Construire Next.js
RUN echo "=== Lancement du build Next.js ===" && \
    bunx next build && \
    echo "=== Build Next.js terminé ==="

# ===============================
# Étape 2 : Image finale légère
# ===============================
FROM oven/bun:1.1.21 AS runner
WORKDIR /app

# Copier le code compilé depuis l'étape précédente
COPY --from=builder /app /app

# Se placer dans le dossier de l'app web
WORKDIR /app/apps/web

# Exposer le port utilisé par Next.js
EXPOSE 3000

# Lancer l'application
CMD ["bunx", "next", "start"]
