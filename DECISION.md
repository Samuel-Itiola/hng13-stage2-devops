# Implementation Decisions

## Nginx Upstream Configuration

**Primary/Backup Strategy**: Used `backup` directive for Green service, ensuring Blue handles all traffic normally while Green only receives traffic when Blue fails.

**Tight Timeouts**: Set 2-second timeouts for quick failure detection:
- `proxy_connect_timeout: 2s`
- `proxy_send_timeout: 2s` 
- `proxy_read_timeout: 2s`

**Retry Policy**: Configured `proxy_next_upstream` to retry on `error timeout http_500 http_502 http_503 http_504` with max 2 tries, ensuring client requests succeed even when primary fails.

**Health Detection**: Used `max_fails=1 fail_timeout=5s` for rapid failure detection and recovery.

## Docker Compose Design

**Template Substitution**: Used `envsubst` in Nginx container to dynamically generate config from environment variables, enabling parameterization without external tools.

**Port Exposure**: Exposed both Blue (8081) and Green (8082) directly for chaos testing while routing main traffic (8080) through Nginx.

**Environment Variables**: Passed `APP_POOL` and `RELEASE_ID` to containers so applications can return correct headers.

## Key Benefits

- **Zero Downtime**: Automatic failover with no client-visible errors
- **Fast Detection**: 2-second timeouts ensure quick failure detection  
- **Simple Operations**: Single `docker-compose up` deployment
- **Full Parameterization**: CI-friendly via `.env` variables
- **Header Preservation**: Applications control their own identity headers