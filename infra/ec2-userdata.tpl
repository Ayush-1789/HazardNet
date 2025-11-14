#!/bin/bash
#cloud-config
package_update: true
packages:
  - nginx

runcmd:
  - curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  - apt-get install -y nodejs git build-essential
  - npm install -g pm2
  - mkdir -p /var/www/hazardnet
  - cd /var/www/hazardnet
  - if [ ! -d backend ]; then git clone https://github.com/your-repo/HazardNet.git . ; fi
  - cd backend
  - npm ci --production
  - pm2 start server.js --name hazardnet --watch --env production || true
  - pm2 save
  - systemctl enable nginx
  - systemctl restart nginx

# nginx: create basic conf
write_files:
  - path: /etc/nginx/sites-available/hazardnet
    content: |
      server {
        listen 80;
        server_name _;
        location / {
          proxy_pass http://127.0.0.1:8080;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection 'upgrade';
          proxy_set_header Host $host;
          proxy_cache_bypass $http_upgrade;
        }
      }
  - path: /etc/nginx/sites-enabled/hazardnet
    content: |
      include /etc/nginx/sites-available/hazardnet;

  - path: /etc/pm2/conf.d/hazardnet.env
    content: |
      PORT=8080

final_message: "HazardNet cloud-init finished"
