# Multi-stage build for maximum optimization
FROM node:25-alpine AS base

# Install dependencies stage
FROM base AS deps
RUN apk add --no-cache libc6-compat ca-certificates

WORKDIR /app

COPY package.json package-lock.json* ./

# Clean install with legacy peer deps to handle Material Tailwind conflicts
# Add platform-specific sharp installation for Alpine Linux
RUN npm ci --no-audit --no-fund --legacy-peer-deps || \
    (rm -f package-lock.json && npm install --no-audit --no-fund --legacy-peer-deps) && \
    npm install --platform=linuxmusl --arch=x64 sharp && \
    npm cache clean --force

# Build stage
FROM base AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Add these ARGs to accept build-time environment variables
ARG NEXT_PUBLIC_API_URL
ARG NEXT_PUBLIC_API_PREFIX
ARG NEXT_PUBLIC_GOOGLE_MAPS_API_KEY

# Set them as environment variables for the build
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_PREFIX=$NEXT_PUBLIC_API_PREFIX
ENV NEXT_PUBLIC_GOOGLE_MAPS_API_KEY=$NEXT_PUBLIC_GOOGLE_MAPS_API_KEY
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

RUN npm run build

# Production runner stage
FROM base AS runner
# Install necessary packages for SSL/networking and debugging
RUN apk add --no-cache \
    dumb-init \
    ca-certificates \
    wget \
    curl \
    openssl

# Update CA certificates and ensure they're properly configured
RUN update-ca-certificates

# Create SSL cert directory and set proper permissions
RUN mkdir -p /etc/ssl/certs && \
    chmod 755 /etc/ssl/certs

WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=4545
ENV HOSTNAME="0.0.0.0"
# Ensure Node.js uses the system CA certificates
ENV SSL_CERT_DIR=/etc/ssl/certs
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy all necessary files from the builder stage
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./package.json

USER nextjs

EXPOSE 4545

ENTRYPOINT ["dumb-init", "--"]

CMD ["npm", "run", "start"]
