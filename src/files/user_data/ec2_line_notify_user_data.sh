#!/bin/bash
# docker導入
yum install -y docker
systemctl start docker
curl -L "https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# アプリケーションコード導入
yum -y install git
mkdir /var/www
cd /var/www
git clone https://github.com/tatsukoni-pra/laravel-line-notify-demo-v1.git
cd laravel-line-notify-demo-v1
/usr/local/bin/docker-compose up -d
docker exec app sh bin/setup.sh
