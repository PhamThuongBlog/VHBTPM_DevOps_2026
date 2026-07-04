# ===== Stage 1: BUILD =====
FROM node:18-alpine AS builder
WORKDIR /app
COPY app/package.json .
RUN npm install --production

# ===== Stage 2: PRODUCTION =====
FROM node:18-alpine
WORKDIR /app

# Copy dependencies từ stage build
COPY --from=builder /app/node_modules ./node_modules
COPY app/ .

# Non-root user (bảo mật)
RUN addgroup -g 1001 -S appgroup && adduser -S appuser -u 1001 -G appgroup
USER appuser

EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "server.js"]
