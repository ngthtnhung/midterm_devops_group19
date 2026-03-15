# Phase 2 - Traditional Deployment on Ubuntu Cloud Server

## 1. Phase Overview

Phase 2 deploys the application directly on a cloud-based Ubuntu server without containerization. All services run natively on the host OS to preserve a clear conceptual distinction from Phase 3 (container-based deployment).

This phase focuses on conventional server administration: provisioning infrastructure, preparing the runtime, securing access, configuring a database, and ensuring operational stability.

---

## 2. Provisioning and Securing the Cloud Server

### Cloud Provider and Instance

Provider: AWS EC2  
Region: us-east-1  
Instance type: t3.micro (Free Tier eligible)  
AMI: Ubuntu Server 24.04 LTS (HVM), SSD Volume Type  
Architecture: 64-bit (x86)  
Storage: 8 GiB gp3  
Key pair: `devops-midterm.pem` (RSA)

Public IP (used in DNS A record): `18.232.145.23`

### Security Group (Least Privilege)

Security group name: `devops-midterm`  
Inbound rules:

- SSH (TCP 22) - Source: My IP only
- HTTP (TCP 80) - Source: 0.0.0.0/0
- HTTPS (TCP 443) - Source: 0.0.0.0/0

Outbound rules:

- All traffic - 0.0.0.0/0

No other ports are open. Port 3000 remains closed externally.

Evidence:

- `phase2/evidence/instance-security-group.png`

---

## 3. Preparing the Runtime Environment

The automation script from Phase 1 (`phase1/scripts/setup.sh`) was executed to install required runtimes and system packages.

Commands:

```bash
git clone https://github.com/ngthtnhung/midterm_devops_group19.git
cd midterm_devops_group19/phase1/scripts
chmod +x setup.sh
./setup.sh
```

Runtime verification:

```bash
node -v
# v18.20.8
npm -v
# 10.8.2
```

Evidence:

- `phase2/evidence/pm2-logs-db-connected.png`

---

## 4. Database Configuration and Connectivity

Database choice: MongoDB (local installation on the same Ubuntu server).

Install and enable MongoDB 7.0:

```bash
sudo apt install -y gnupg curl
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
sudo systemctl status mongod
```

Application startup confirms DB connectivity:

```bash
npm install
npm start
# Connected to MongoDB — using mongodb as data source.
# Server listening on port http://localhost:3000
```

Evidence:

- `phase2/evidence/mongodb-service-running.png`
- `phase2/evidence/mongodb-data-proof.png`

---

## 5. Deploying and Operating the Application

PM2 was selected to ensure the application restarts automatically after a reboot.

Commands:

```bash
sudo npm install -g pm2
pm2 start main.js --name devops-midterm
pm2 save
pm2 startup
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu
pm2 list
```

Reboot validation:

```bash
sudo reboot
pm2 list
# status: online
```

Evidence:

- `phase2/evidence/pm2-running.png`
- `phase2/evidence/data-persistent-after-reboot.png`

---

## 6. Reverse Proxy Configuration

Nginx was installed and configured as a reverse proxy for the Node.js app on port 3000.

Install and enable:

```bash
sudo apt update
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

Final Nginx config (`/etc/nginx/sites-available/default`):

```nginx
server {
    listen 80;
    server_name devops-midterm-2026.online www.devops-midterm-2026.online;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Reload:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

Evidence:

- `phase2/evidence/nginx-reverse-proxy-config.png`
- `phase2/evidence/nginx-running.png`

---

## 7. Domain and HTTPS Configuration

Official domain: `devops-midterm-2026.online`

Domain registrar: Hostinger  
DNS record (A):

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | 18.232.145.23 | 300 |

DNS verification:

```bash
nslookup devops-midterm-2026.online
```

Enable HTTPS with Let's Encrypt + Certbot:

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d devops-midterm-2026.online -d www.devops-midterm-2026.online
```

Verify HTTPS:

```bash
curl -I https://devops-midterm-2026.online
```

Evidence:

- `phase2/evidence/dns-config.png`
- `phase2/evidence/https-active.png`
- `phase2/evidence/https-certificate.png`

---

## 8. Expected Operational State

The deployment meets the required operational criteria:

- Application accessible via the public domain over HTTPS
- MongoDB connection active
- File upload functionality works
- PM2 ensures persistence across server reboots
- Nginx proxies inbound traffic to the app

Evidence bundle:

- `phase2/evidence/`
- `phase2/evidence/create-product-on-ui.png`
- `phase2/evidence/created-product-on-ui.png`
- `phase2/evidence/uploads-folder-proof.png`
- `phase2/evidence/curl-http-https-response.png`
