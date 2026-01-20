# Use Node.js LTS slim image
FROM node:20-slim

# Set working directory
WORKDIR /app

# Set environment variables
ENV NODE_ENV=production \
    PORT=8080 \
    APP_VERSION=v1.0.0 \
    ENVIRONMENT=production

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy application file
COPY app.js /app/

# Change ownership
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8080/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Run the application
CMD ["node", "app.js"]
