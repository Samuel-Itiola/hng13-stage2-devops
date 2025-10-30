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