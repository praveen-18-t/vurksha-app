# Multi-stage Dockerfile for Node.js microservices
# Optimized for production with minimal image size

# ============================================
# Stage 1: Base
# ============================================
FROM node:20-alpine AS base

# Install security updates
RUN apk update && apk upgrade --no-cache

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs

# Set working directory
WORKDIR /app

# ============================================
# Stage 2: Dependencies
# ============================================
FROM base AS deps

# Install dependencies for native modules
RUN apk add --no-cache libc6-compat python3 make g++

# Copy package files
COPY package.json package-lock.json* ./
COPY prisma ./prisma/

# Install production dependencies
RUN npm ci --only=production && \
    npx prisma generate && \
    npm cache clean --force

# ============================================
# Stage 3: Builder
# ============================================
FROM base AS builder

# Install all dependencies for building
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build TypeScript
RUN npm run build

# ============================================
# Stage 4: Production
# ============================================
FROM base AS production

# Set environment
ENV NODE_ENV=production
ENV PORT=3000

# Copy built assets
COPY --from=deps --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/prisma ./prisma
COPY --chown=nodejs:nodejs package.json ./

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health/live || exit 1

# Start application
CMD ["node", "dist/index.js"]
