# platform-one/docker/frontend/Dockerfile
FROM node:18-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
COPY apps/frontend/package*.json ./apps/frontend/
COPY packages/common/package*.json ./packages/common/
COPY packages/ui-components/package*.json ./packages/ui-components/
RUN npm ci

# Build packages
COPY packages/common ./packages/common
COPY packages/ui-components ./packages/ui-components
RUN npm run build --workspace=@platform-one/common
RUN npm run build --workspace=@platform-one/ui-components

# Build frontend
COPY apps/frontend ./apps/frontend
RUN npm run build --workspace=@platform-one/frontend

# Production image
FROM nginx:alpine
COPY --from=builder /app/apps/frontend/dist /usr/share/nginx/html
COPY docker/frontend/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]