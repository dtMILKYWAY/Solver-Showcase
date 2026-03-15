# ButterMath Multi-Stage Dockerfile
# Backend: Python with Granian
# Frontend: Static build (served by Caddy)

FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS backend-builder

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy backend files
COPY backend/pyproject.toml backend/uv.lock* ./

# Install dependencies using uv
RUN uv sync --frozen --no-dev

# Copy application code
COPY backend/ ./

# Production stage
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy Python dependencies from builder
COPY --from=backend-builder /app/.venv /app/.venv

# Copy application code
COPY backend/ ./

# Create logs directory
RUN mkdir -p /app/logs

# Set environment variables
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
ENV ENVIRONMENT=production

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost:8000/health || exit 1

# Run with Granian
CMD ["granian", "app:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4", "--threads", "2", "--http", "1"]
