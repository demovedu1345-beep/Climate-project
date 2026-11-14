# Multi-stage Dockerfile for AstroKites Full-Stack Climate Platform
# Stage 1: Build React 19 Frontend (Vite)
FROM node:20-alpine AS frontend-builder
WORKDIR /app/AstroKites
COPY AstroKites/package*.json AstroKites/.npmrc ./
RUN npm install
COPY AstroKites/ ./
RUN npm run build

# Stage 2: Python FastAPI Backend + Unified SPA Server
FROM python:3.10-slim AS runner
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
COPY --from=frontend-builder /app/AstroKites/dist ./AstroKites/dist

ENV PORT=8000
ENV HOST=0.0.0.0
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/ || exit 1

CMD ["python", "Backend.py"]
