# Nginx Proxy docker-compose

[Using Nginx Proxy Docker Image](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion/wiki/Basic-usage)

## Installation

You need to create the directories for the volumes :

```bash
mkdir -p /path/to/nginx-proxy/certs
mkdir -p /path/to/nginx-proxy/html
mkdir -p /path/to/nginx-proxy/vhost.d
```

Start the composition :

```bash
docker-compose up -d
```
