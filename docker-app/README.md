# Docker Demo Application

A simple containerized HTTP server application demonstrating Docker best practices.

## Application Overview

This is a simple Node.js HTTP server that provides:
- JSON API endpoints (`/` and `/health`)
- Environment variable configuration
- Health check endpoint
- No external dependencies (uses Node.js built-in modules only)

## Project Structure

```
docker-app/
├── app.js             # Main application code
├── package.json       # Node.js package metadata
├── Dockerfile         # Container build instructions
├── docker-compose.yml # Multi-container orchestration
├── .dockerignore     # Files to exclude from build context
└── README.md         # This file
```

## Building the Docker Image

### Basic build:
```bash
docker build -t safeharbor/demo-app:latest .
```

### Build with custom tag:
```bash
docker build -t safeharbor/demo-app:v1.0.0 .
```

### Build with build arguments:
```bash
docker build \
  --build-arg APP_VERSION=v1.0.0 \
  -t safeharbor/demo-app:latest .
```

## Running the Container

### Basic run:
```bash
docker run -d \
  --name demo-app \
  -p 8080:8080 \
  safeharbor/demo-app:latest
```

### Run with environment variables:
```bash
docker run -d \
  --name demo-app \
  -p 8080:8080 \
  -e APP_MESSAGE="Custom message" \
  -e APP_VERSION="v2.0.0" \
  -e ENVIRONMENT="production" \
  safeharbor/demo-app:latest
```

### Run with environment file:
```bash
docker run -d \
  --name demo-app \
  -p 8080:8080 \
  --env-file .env \
  safeharbor/demo-app:latest
```

## Using Docker Compose

### Start the application:
```bash
docker-compose up -d
```

### View logs:
```bash
docker-compose logs -f
```

### Stop the application:
```bash
docker-compose down
```

### Rebuild and restart:
```bash
docker-compose up -d --build
```

## Testing the Application

### Check health endpoint:
```bash
curl http://localhost:8080/health
```

### Get application info:
```bash
curl http://localhost:8080/
```

### Test with formatted output:
```bash
curl http://localhost:8080/ | jq
```

## Container Management

### View running containers:
```bash
docker ps
```

### View container logs:
```bash
docker logs demo-app
docker logs -f demo-app  # Follow logs
```

### Execute commands in container:
```bash
docker exec -it demo-app /bin/sh
```

### Inspect container:
```bash
docker inspect demo-app
```

### View container stats:
```bash
docker stats demo-app
```

### Stop container:
```bash
docker stop demo-app
```

### Remove container:
```bash
docker rm demo-app
```

### Remove image:
```bash
docker rmi safeharbor/demo-app:latest
```

## Dockerfile Best Practices

1. **Multi-stage builds**: Not needed for this simple app, but useful for production
2. **Non-root user**: Application runs as `appuser` instead of root
3. **Layer caching**: Copy package.json first (if dependencies exist) to leverage cache
4. **Health checks**: Built-in health check for container orchestration
5. **Minimal base image**: Using `node:20-slim` for smaller image size
6. **Environment variables**: Configurable via ENV directives
7. **Working directory**: Explicit WORKDIR for clarity
8. **Security**: Running as non-root user reduces attack surface
9. **No dependencies**: Uses only Node.js built-in modules (http, os)

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8080` | Server listening port |
| `APP_VERSION` | `v1.0.0` | Application version |
| `ENVIRONMENT` | `production` | Environment name |
| `APP_MESSAGE` | `Welcome to SafeHarbor Demo App!` | Custom message |

## API Endpoints

### `GET /`
Returns application information including version, environment, and status.

**Response:**
```json
{
  "message": "Welcome to SafeHarbor Demo App!",
  "version": "v1.0.0",
  "environment": "development",
  "timestamp": "2024-01-01T12:00:00",
  "hostname": "container-id",
  "status": "healthy"
}
```

### `GET /health`
Health check endpoint for orchestration systems.

**Response:**
```json
{
  "status": "healthy"
}
```

## Key Features

1. **Lightweight**: Uses only Node.js built-in modules (no npm packages)
2. **Simple**: Minimal code - easy to understand and discuss
3. **Configurable**: Environment-based configuration
4. **Health checks**: Built-in health endpoint
5. **Security**: Runs as non-root user
6. **Multi-platform**: Works on Linux, macOS, Windows

## Optional Enhancements

For production use, consider adding:
- **Multi-stage builds**: Reduce final image size
- **Secrets management**: Use Docker secrets or external secret managers
- **Metrics**: Add Prometheus metrics endpoint
- **TLS/HTTPS**: Add SSL/TLS support
- **Rate limiting**: Implement request rate limiting
- **Graceful shutdown**: Handle SIGTERM for clean shutdowns
- **Log aggregation**: Send logs to centralized logging system
