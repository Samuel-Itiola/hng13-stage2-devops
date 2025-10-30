<<<<<<< HEAD
# Blue/Green Deployment with Nginx Auto-Failover

A production-ready blue/green deployment setup with automatic failover using Nginx and Docker Compose.

## Quick Start

1. **Clone and setup:**
   ```bash
   git clone <your-repo-url>
   cd blue-green-nginx-failover
   cp .env.example .env
   ```

2. **Install dependencies and start:**
   ```bash
   cd app && npm install && cd ..
   docker-compose up -d
   ```

3. **Test the setup:**
   ```bash
   curl localhost:8080/version  # Should show blue pool
   ```

## Testing Failover

1. **Trigger chaos on blue:**
   ```bash
   curl -X POST localhost:8081/chaos/start
   ```

2. **Verify automatic failover:**
   ```bash
   curl localhost:8080/version  # Should now show green pool
   ```

3. **Restore blue:**
   ```bash
   curl -X POST localhost:8081/chaos/stop
   ```

## Manual Pool Switching

1. **Edit `.env` file:**
   ```bash
   ACTIVE_POOL=green  # Switch to green as primary
   ```

2. **Reload nginx:**
   ```bash
   docker-compose exec nginx nginx -s reload
   ```

## Environment Variables

- `BLUE_IMAGE`: Docker image for blue deployment
- `GREEN_IMAGE`: Docker image for green deployment  
- `ACTIVE_POOL`: Primary pool (blue/green)
- `RELEASE_ID_BLUE`: Blue release identifier
- `RELEASE_ID_GREEN`: Green release identifier
- `PORT`: External port for nginx (default: 8080)

## Architecture

- **Nginx** (port 8080): Load balancer with failover
- **Blue App** (port 8081): Primary application instance
- **Green App** (port 8082): Backup application instance

Nginx automatically routes traffic to the healthy instance and includes `X-App-Pool` and `X-Release-Id` headers in responses.
=======
# Blue/Green Deployment with Nginx Upstreams

This project implements a Blue/Green deployment strategy using Nginx upstreams with automatic failover and manual toggle capabilities.

## Quick Start

1. **Setup Environment**
   ```bash
   cp .env.example .env
   # Edit .env with your image references and configuration
   ```

2. **Deploy**
   ```bash
   docker-compose up -d
   ```

3. **Test Endpoints**
   - Main service: http://localhost:8080/version
   - Blue direct: http://localhost:8081/version
   - Green direct: http://localhost:8082/version

## Configuration

Edit `.env` file with your parameters:
- `BLUE_IMAGE` / `GREEN_IMAGE`: Container image references
- `ACTIVE_POOL`: Primary pool (blue/green)
- `RELEASE_ID_BLUE` / `RELEASE_ID_GREEN`: Release identifiers
- `PORT`: Application port (default: 3000)

## Failover Testing

1. **Trigger Blue failure:**
   ```bash
   curl -X POST http://localhost:8081/chaos/start?mode=error
   ```

2. **Verify automatic switch to Green:**
   ```bash
   curl http://localhost:8080/version
   # Should return X-App-Pool: green
   ```

3. **Stop chaos:**
   ```bash
   curl -X POST http://localhost:8081/chaos/stop
   ```

## Architecture

- **Nginx**: Load balancer with upstream failover (port 8080)
- **Blue Service**: Primary application instance (port 8081)
- **Green Service**: Backup application instance (port 8082)

Nginx automatically routes traffic to Green when Blue fails, with zero client-visible errors.
>>>>>>> origin/main
