#!/bin/bash
# ------------------------------
# Home/Travel Lab Auto Setup Pi 4
# ------------------------------

# Update OS
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y curl git software-properties-common apt-transport-https ca-certificates

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker pi

# Install Docker Compose
sudo apt install -y libffi-dev libssl-dev python3 python3-pip
sudo pip3 install docker-compose

# Maak mappen voor data
mkdir -p ~/home-lab/plex_media
mkdir -p ~/home-lab/plex_data
mkdir -p ~/home-lab/nextcloud_data
mkdir -p ~/home-lab/pihole_data
mkdir -p ~/home-lab/dnsmasq_data
mkdir -p ~/home-lab/heimdall_data

cd ~/home-lab

# Maak docker-compose.yml
cat <<EOL > docker-compose.yml
version: '3'

services:
  pihole:
    image: pihole/pihole:latest
    container_name: pihole
    environment:
      TZ: "Europe/Amsterdam"
      WEBPASSWORD: "pi-hole"
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "8081:80"
    restart: unless-stopped
    volumes:
      - ./pihole_data:/etc/pihole
      - ./dnsmasq_data:/etc/dnsmasq.d

  nextcloud:
    image: nextcloud:latest
    container_name: nextcloud
    ports:
      - "8082:80"
    volumes:
      - ./nextcloud_data:/var/www/html
    restart: unless-stopped

  plex:
    image: linuxserver/plex
    container_name: plex
    environment:
      PUID: 1000
      PGID: 1000
      TZ: "Europe/Amsterdam"
    ports:
      - "32400:32400"
    volumes:
      - ./plex_data:/config
      - ./plex_media:/media
    restart: unless-stopped

  heimdall:
    image: linuxserver/heimdall
    container_name: heimdall
    ports:
      - "8080:80"
    restart: unless-stopped

  openwrt:
    image: owrt/docker-openwrt
    container_name: openwrt
    privileged: true
    network_mode: host
    restart: unless-stopped

volumes:
  pihole_data:
  dnsmasq_data:
  nextcloud_data:
  plex_data:
EOL

# Start containers
docker-compose up -d

echo "---------------------------------"
echo "Setup voltooid!"
echo "Open Heimdall: http://<Pi-IP>:8080"
echo "Pi-hole: http://<Pi-IP>:8081/admin"
echo "Nextcloud: http://<Pi-IP>:8082"
echo "Plex: http://<Pi-IP>:32400/web"
echo "OpenWRT (optioneel): http://<Pi-IP>"
echo "---------------------------------"
