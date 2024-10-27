{\rtf1}# platform-one/docker/backend/Dockerfile
FROM node:18-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
COPY apps/backend/package*.json ./apps/backend/
COPY packages/common/package*.json ./packages/common/
RUN npm ci

# Build packages
COPY packages/common ./packages/common
RUN npm run build --workspace=@platform-one/common

# Build backend
COPY apps/backend ./apps/backend
RUN npm run build --workspace=@platform-one/backend

# Production image
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/apps/backend/dist ./dist
COPY --from=builder /app/apps/backend/package.json ./
EXPOSE 8000