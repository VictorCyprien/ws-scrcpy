# syntax=docker/dockerfile:1

# Build stage: on n’installe que les devDependencies pour lancer webpack
ARG NODE_VERSION=16-bullseye
FROM node:${NODE_VERSION} AS builder
WORKDIR /app

# Seuls les fichiers de lock et manifest pour optimiser le cache
COPY package*.json ./

# Installe toutes les deps (dev + prod) pour compiler via webpack
RUN npm ci --no-audit --no-fund

# Reste du code
COPY . .

# Build frontend + backend dans /dist
RUN npm run dist


# Runtime stage: image minimale avec seulement les deps nécessaires à l’exécution
FROM node:${NODE_VERSION}
WORKDIR /app

# Outils nécessaires à certains modules natifs (ex: node-pty) + adb requis au runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    adb \
    python3 \
    make \
    g++ \
 && rm -rf /var/lib/apt/lists/*

# Copie des artefacts buildés
COPY --from=builder /app/dist /app

# Installation des deps de prod pour le package.json généré dans /app
RUN npm install --omit=dev --no-audit --no-fund

# Config par défaut (surchargeable)
ENV NODE_ENV=production \
    WS_SCRCPY_PATHNAME=/

# Port par défaut du serveur HTTP
EXPOSE 8001

CMD ["npm", "start"]


