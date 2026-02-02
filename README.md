# Nginx Reverse Proxy with Let's Encrypt

Automated reverse proxy using jwilder/nginx-proxy with automatic SSL certificate generation via Let's Encrypt.

**Documentation:**
- [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy)
- [Let's Encrypt Companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion/wiki/Basic-usage)

---

## Quick Start

### 1. Create Reverse Proxy Network

```bash
# Create the shared network for all services
docker network create reverse-proxy
```

### 2. Create Volume Directories

```bash
# Create directories for persistent volumes
mkdir -p ./certs
mkdir -p ./vhost.d
mkdir -p ./html
```

### 3. Start Services

```bash
# Using modern Docker Compose (v2+)
docker compose up -d

# Wait for services to start
sleep 10

# Check status
docker compose ps

# View logs
docker compose logs -f
```

### 4. Verify Proxy is Running

```bash
# Check if nginx-proxy is listening on ports 80 and 443
curl http://localhost
```

---

## Adding Services Behind the Proxy

Any Docker service can be proxied by setting environment variables:

```yaml
services:
  my-app:
    image: my-app:latest
    environment:
      - VIRTUAL_HOST=myapp.example.com
      - LETSENCRYPT_HOST=myapp.example.com
      - LETSENCRYPT_EMAIL=admin@example.com
    networks:
      - reverse-proxy
    restart: always

networks:
  reverse-proxy:
    external: true
```

The proxy will automatically:
- ✅ Route traffic from `myapp.example.com` to your service
- ✅ Generate SSL certificate via Let's Encrypt
- ✅ Redirect HTTP → HTTPS automatically

---

## Configuration

### Enable DEBUG Mode

Uncomment in `docker-compose.yml`:

```yaml
environment:
  - DEBUG=true
```

Then view logs:
```bash
docker compose logs -f nginx-proxy-letsencrypt
```

### Custom Nginx Configuration

For advanced nginx configuration per service:

```bash
# Create custom config
echo "client_max_body_size 2000M;" > ./vhost.d/myapp.example.com

# Reload nginx
docker compose exec nginx-proxy nginx -s reload
```

### Email for Let's Encrypt

The email address must be set in each service's environment:

```yaml
environment:
  - LETSENCRYPT_EMAIL=your-email@example.com
```

---

## Volumes

| Volume | Purpose | Path |
|--------|---------|------|
| **certs** | SSL certificates (Let's Encrypt) | `/etc/nginx/certs` |
| **vhost** | Custom per-domain nginx configs | `/etc/nginx/vhost.d` |
| **html** | Acme challenge responses | `/usr/share/nginx/html` |

---

## Networking

All services must be connected to the `reverse-proxy` network:

```yaml
networks:
  reverse-proxy:
    external: true
```

The network is shared across multiple docker-compose projects.

---

## Troubleshooting

### Certificate Not Generated

```bash
# Check Let's Encrypt companion logs
docker compose logs nginx-proxy-letsencrypt

# Common issues:
# - Email not set in service environment
# - Domain not pointing to server IP
# - Port 443 not accessible from internet
```

### Nginx Not Routing Traffic

```bash
# Check nginx proxy logs
docker compose logs nginx-proxy

# Reload configuration
docker compose exec nginx-proxy nginx -s reload
```

### Restart Services

```bash
# Stop all services
docker compose down

# Remove volumes (WARNING: Deletes certificates!)
# rm -rf ./certs ./vhost.d ./html

# Start again
docker compose up -d
```

---

## Security Notes

- ✅ Automatically renews SSL certificates (90 days before expiry)
- ✅ Uses Let's Encrypt (free SSL/TLS certificates)
- ✅ Redirects HTTP → HTTPS automatically
- ✅ Supports multiple domains per service via VIRTUAL_HOST
- ⚠️ Keep port 443 open for certificate renewal
- ⚠️ Keep port 80 open for ACME challenges

---

## Docker Compose Version

Requires Docker Compose v2+ (use `docker compose` instead of `docker-compose`)

```bash
# Check version
docker compose version
```

---

## Examples

### Multiple Domains for One Service

```yaml
environment:
  - VIRTUAL_HOST=example.com,www.example.com
  - LETSENCRYPT_HOST=example.com,www.example.com
```

### Different Port

```yaml
environment:
  - VIRTUAL_HOST=myapp.example.com
  - VIRTUAL_PORT=8080  # If app doesn't listen on 80
```

### Static Files (No Service Backend)

```yaml
services:
  nginx-proxy:
    # ... (proxy configuration)
    volumes:
      - ./static-site:/usr/share/nginx/html/static
```

---

**Last Updated:** 2026-02-02
