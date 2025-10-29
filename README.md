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