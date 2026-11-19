# Temporary image: nginx-proxy 1.11.6 on a patched nginx base.
# nginx-proxy 1.11.6 ships nginx 1.31.3, vulnerable to CVE-2026-123007,
# CVE-2026-118899, CVE-2026-123633, CVE-2026-123634, CVE-2026-121810
# (fixed in nginx 1.31.9). Go back to nginxproxy/nginx-proxy once
# upstream releases an image based on nginx >= 1.31.9.
FROM docker.io/nginxproxy/nginx-proxy:1.11.6 AS upstream

FROM docker.io/library/nginx:1.31.9

ENV NGINX_PROXY_VERSION=1.11.6 \
   DOCKER_GEN_VERSION=unknown \
   DOCKER_HOST=unix:///tmp/docker.sock

COPY --from=upstream /etc/nginx/nginx.conf /etc/nginx/network_internal.conf /etc/nginx/
RUN mkdir -p /etc/nginx/toplevel.conf.d /etc/nginx/dhparam /etc/nginx/certs /usr/share/nginx/html/errors
COPY --from=upstream /usr/local/bin/forego /usr/local/bin/docker-gen /usr/local/bin/
COPY --from=upstream /app /app/
WORKDIR /app/

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
