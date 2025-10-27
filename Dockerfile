# ---- Base image ----
FROM node:18-alpine

# ---- Create app directory ----
WORKDIR /app

# ---- Copy package files ----
COPY package*.json ./

# ---- Install dependencies ----
RUN npm install --omit=dev --workspaces

# ---- Copy the rest of the app ----
COPY . .

# ---- Build if needed (for Next.js) ----
RUN npm run build || true

# ---- Expose port ----
EXPOSE 3000

# ---- Start the app ----
CMD ["npm", "start"]
