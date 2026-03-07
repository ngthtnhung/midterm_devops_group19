# Phase 3 — Docker Compose Deployment (Web + MongoDB)

## Objectives
- Containerize the web app and MongoDB with Docker Compose
- Pull the web image from Docker Hub (no server-side build)
- Run behind a reverse proxy with HTTPS and a public domain
- Persist product data and uploaded images across restart/reboot

## Server prerequisites
- Ubuntu 22.04+
- Open inbound ports: 22 (SSH), 80 (HTTP), 443 (HTTPS)
- Docker CE + Docker Compose plugin
- Nginx (or Caddy) for reverse proxy
- A domain pointing to the server public IP, Certbot for TLS

## Build & push a multi‑arch image (on your dev machine)
```bash
docker login
docker buildx create --use
docker buildx inspect --bootstrap

docker buildx build --platform linux/amd64,linux/arm64 \
  -t docker.io/hnt04115/midterm_devops:1.1 \
  -f phase3/Dockerfile \
  --push .

# verify manifest platforms
docker buildx imagetools inspect docker.io/hnt04115/midterm_devops:1.1
```

## Deploy on server (pull image, no build)
```bash
export WEB_IMAGE=docker.io/hnt04115/midterm_devops:1.1
sudo docker compose -f ~/midterm_devops_group19/phase3/docker-compose.yml pull
sudo docker compose -f ~/midterm_devops_group19/phase3/docker-compose.yml up -d
sudo docker compose -f ~/midterm_devops_group19/phase3/docker-compose.yml ps
sudo docker compose -f ~/midterm_devops_group19/phase3/docker-compose.yml logs -f web
# Ctrl+C to exit
```

## Reverse proxy + HTTPS (Nginx)
- Upstream to the app: `proxy_pass http://127.0.0.1:3000;`
- Increase upload limit if needed: `client_max_body_size 10M;`
```bash
sudo nginx -t && sudo systemctl reload nginx
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d devops-midterm-2026.online
```

## Verification
- Perform CRUD + image upload on the HTTPS domain
- Ensure data/images persist after restart and reboot:
```bash
sudo docker compose -f ~/midterm_devops_group19/phase3/docker-compose.yml restart
sudo reboot
# SSH back in, then check:
sudo docker compose -f ~/midterm_devops_group19/phase3/docker-compose.yml ps
sudo docker compose -f ~/midterm_devops_group19/phase3/docker-compose.yml logs -f web
```

## Docker Compose summary
- Services:
  - `mongo`: image mongo:6.0, volume `mongo_data`, no public 27017
  - `web`: image `${WEB_IMAGE:-docker.io/hnt04115/midterm_devops:1.1}`, publishes 3000, volume `uploads_data`
- Volumes: `mongo_data`, `uploads_data`
- Web env: `PORT=3000`, `MONGO_URI=mongodb://mongo:27017/products_db`

## Troubleshooting
- Port 3000 “address already in use”: stop host processes (PM2/systemd/node), then `compose up -d`
```bash
sudo ss -lntp | grep :3000 || echo "port 3000 is free"
sudo pkill -f "node main.js" || true
sudo fuser -k 3000/tcp || true
```
- Web fell back to in‑memory: wait for Mongo to be ready, then restart web only
```bash
sudo docker exec midterm_mongo mongosh --quiet --eval 'db.runCommand({ ping: 1 })'
sudo docker compose -f ~/midterm_devops_group19/phase3/docker-compose.yml restart web
```
- Upload 413: increase `client_max_body_size` in Nginx and reload
- PM2 auto‑start conflicts: remove PM2 startup and disable its service
```bash
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 unstartup systemd -u ubuntu --hp /home/ubuntu
sudo systemctl stop pm2-ubuntu.service && sudo systemctl disable pm2-ubuntu.service && sudo systemctl mask pm2-ubuntu.service
pm2 kill
```

## Submission checklist
- Docker Hub: tag 1.1 (multi‑arch amd64+arm64)
- Server:
  - `docker version`, `docker compose version`
  - `compose ps` + `logs web` show “Connected to MongoDB”
  - `compose config` shows image 1.1, volumes, mongo not published
  - `docker volume ls` + `inspect` Mountpoint for `mongo_data`, `uploads_data`
- Reverse proxy & HTTPS:
  - Nginx `server_name`, `proxy_pass`, `client_max_body_size`, `nginx -t`, `status active`
  - Browser padlock screenshot for HTTPS
- DNS & Security Group:
  - A record points domain → server IP
  - Inbound rules: 22 (your IP), 80/443 (0.0.0.0/0)
- Video: CRUD + upload → compose restart → reboot → data/images persist
