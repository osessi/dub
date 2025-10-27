# Utilise une image Node légère
FROM node:18-alpine AS builder
WORKDIR /app

# Copie tout le projet
COPY . .

# Va dans le bon dossier (Dub utilise apps/web comme dossier principal)
WORKDIR /app/apps/web

# Installe les dépendances et build
RUN npm install -g pnpm
RUN pnpm install --prod --filter ./apps/web
RUN pnpm run build

# ---- Runner stage ----
FROM node:18-alpine
WORKDIR /app

# Copie juste le build depuis le builder
COPY --from=builder /app/apps/web ./

# Expose le port (Dub utilise 3000)
EXPOSE 3000

CMD ["pnpm", "start"]
