#!/bin/bash

mkdir -p {data,docker_apps}
mkdir -p data/{torrents,media}
mkdir -p data/torrents/{movies,tv}
mkdir -p data/media/{movies,tv}

mkdir -p docker_apps/{bazarr,file_browser,heimdall,jackett,jellyfin,monitoring,nginx,openbooks,qbittorrent,radarr,sonarr,unmanic,uptime_kuma,wireguard}
mkdir /etc/prometheus/

touch docker_apps/bazarr/docker-compose.yml
touch docker_apps/file_browser/docker-compose.yml
touch docker_apps/heimdall/docker-compose.yml
touch docker_apps/jackett/docker-compose.yml
touch docker_apps/jellyfin/docker-compose.yml
touch docker_apps/monitoring/docker-compose.yml
touch docker_apps/nginx/docker-compose.yml
touch docker_apps/openbooks/docker-compose.yml
touch docker_apps/qbittorrent/docker-compose.yml
touch docker_apps/radarr/docker-compose.yml
touch docker_apps/sonarr/docker-compose.yml
touch docker_apps/unmanic/docker-compose.yml
touch docker_apps/uptime_kuma/docker-compose.yml
touch docker_apps/wireguard/docker-compose.yml
touch etc/prometheus/prometheus.yml

echo "global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  # external_labels:
  #  monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'
    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']

  # Example job for node_exporter
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['node_exporter:9100']

  # Example job for cadvisor
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']" >> /etc/prometheus/prometheus.yml

echo "version: "2.1"
services:
  bazarr:
    image: lscr.io/linuxserver/bazarr
    container_name: bazarr
    environment:
      - PUID=<PUID>
      - PGID=<PGID>
      - TZ=Asia/Kolkata
    volumes:
      - /home/ubuntu/docker_apps/bazarr/config:/config
      - /home/ubuntu/data/media/movies:/movies #optional
      - /home/ubuntu/data/media/tv:/tv #optional
    #ports:
    #  - 6767:6767
    restart: unless-stopped" >> docker_apps/bazarr/docker-compose.yml

echo "version: '3'
services:
  file-browser:
    image: filebrowser/filebrowser
    container_name: file_browser
    user: <PUID>:<PGID>
    ports:
      - 8081:80
    volumes:
      - /home/ubuntu/:/srv/
      - /home/ubuntu/docker_apps/file_browser/filebrowser.db:/database.db
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true" >> docker_apps/file_browser/docker-compose.yml

echo "version: "2.1"
services:
  heimdall:
    image: lscr.io/linuxserver/heimdall
    container_name: heimdall
    environment:
      - PUID=<PUID>
      - PGID=<PGID>
      - TZ=Asia/Kolkata
    volumes:
      - /home/ubuntu/docker_apps/heimdall/config/:/config
    #ports:
    #  - 80:80
    #  - 443:443
    restart: unless-stopped" >> docker_apps/heimdall/docker-compose.yml

echo "version: "2.1"
services:
  jackett:
    image: lscr.io/linuxserver/jackett
    container_name: jackett
    environment:
      - PUID=<PUID>
      - PGID=<PGID>
      - TZ=Asia/Kolkata
      - AUTO_UPDATE=true #optional
      - RUN_OPTS=<run options here> #optional
    volumes:
      - /home/ubuntu/docker_apps/jackett/config/:/config
      - /home/ubuntu/data/:/data
    #ports:
    #  - 9117:9117
    restart: unless-stopped" >> docker_apps/jackett/docker-compose.yml

echo "version: "2.1"
services:
  jellyfin:
    image: lscr.io/linuxserver/jellyfin
    container_name: jellyfin
    environment:
      - PUID=<PUID>
      - PGID=<PGID>
      - TZ=Asia/Kolkata
      - JELLYFIN_PublishedServerUrl=<Enter URL> #optional
    volumes:
      - /home/ubuntu/docker_apps/jellyfin/config/:/config
      - /home/ubuntu/data/media/:/data/media
    #ports:
    #  - 8096:8096
    #  - 8920:8920 #optional
    #  - 7359:7359/udp #optional
    #  - 1900:1900/udp #optional
    restart: unless-stopped" >> docker_apps/jellyfin/docker-compose.yml

echo "version: '3'

volumes:
  prometheus-data:
    driver: local
  grafana-data:
    driver: local

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    #ports:
    #  - "9090:9090"
    volumes:
      - /etc/prometheus:/etc/prometheus
      - prometheus-data:/prometheus
    restart: unless-stopped
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"

  node_exporter:
    image: quay.io/prometheus/node-exporter:latest
    container_name: node_exporter
    command:
      - '--path.rootfs=/host'
    pid: host
    restart: unless-stopped
    volumes:
      - '/:/host:ro,rslave'

  cadvisor:
    image: budry/cadvisor-arm:latest
    container_name: cadvisor
    # ports:
    #   - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    devices:
      - /dev/kmsg
    restart: unless-stopped

  grafana:
    image: grafana/grafana-oss:latest
    container_name: grafana
    #ports:
    #  - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana
    restart: unless-stopped" >> docker_apps/monitoring/docker-compose.yml

echo "version: "3"
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      # These ports are in format <host-port>:<container-port>
      - '80:80' # Public HTTP Port
      - '443:443' # Public HTTPS Port
      - '81:81' # Admin Web Port
      # Add any other Stream port you want to expose
      # - '21:21' # FTP

    # Uncomment the next line if you uncomment anything in the section
    # environment:
      # Uncomment this if you want to change the location of
      # the SQLite DB file within the container
      # DB_SQLITE_FILE: "/data/database.sqlite"

      # Uncomment this if IPv6 is not enabled on your host
      # DISABLE_IPV6: 'true'

    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt" >> docker_apps/nginx/docker-compose.yml

echo "version: '3.3'
services:
  openbooks:
    #ports:
    #  - 8080:80
    volumes:
      - 'booksVolume:/books'
    restart: unless-stopped
    container_name: OpenBooks
    command: --persist
    enviroment:
      - BASE_PATH=/openbooks/
    image: evanbuss/openbooks:latest
volumes:
  booksVolume:" >> docker_apps/openbooks/docker-compose.yml

echo "version: "2.1"
services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent
    container_name: qbittorrent
    environment:
      - PUID=<PUID>
      - PGID=<PGID>
      - TZ=Asia/Kolkata
      - WEBUI_PORT=8080
    volumes:
      - /home/ubuntu/docker_apps/qbittorrent/config:/config
      - /home/ubuntu/data/torrents/:/data/torrents/
      - /home/ubuntu/docker_apps/qbittorrent/vuetorrent:/vuetorrent
    ports:
      - 8080:8080
      - 6881:6881
      - 6881:6881/udp
    restart: unless-stopped" >> docker_apps/qbittorrent/docker-compose.yml

echo "version: "2.1"
services:
  radarr:
    image: lscr.io/linuxserver/radarr
    container_name: radarr
    environment:
      - PUID=<PUID>
      - PGID=<PGID>
      - TZ=Asia/Kolkata
    volumes:
      - /home/ubuntu/docker_apps/radarr/config/:/config
      - /home/ubuntu/data/:/data #optional
    #ports:
    #  - 7878:7878
    restart: unless-stopped" >> docker_apps/radarr/docker-compose.yml

echo "version: "2.1"
services:
  sonarr:
    image: lscr.io/linuxserver/sonarr
    container_name: sonarr
    environment:
      - PUID=<PUID>
      - PGID=<PGID>
      - TZ=Asia/Kolkata
    volumes:
      - /home/ubuntu/docker_apps/sonarr/config/:/config
      - /home/ubuntu/data/:/data
    #ports:
    #  - 8989:8989
    restart: unless-stopped" >> docker_apps/sonarr/docker-compose.yml

echo "version: '2.4'
services:
  unmanic:
    container_name: unmanic
    image: josh5/unmanic:latest
    #ports:
    #  - 8888:8888
    environment:
      - PUID=<PUID>
      - PGID=<PGID>
    volumes:
      - /home/ubuntu/docker_apps/unmanic/config/:/config
      - /home/ubuntu/data/media/movies/:/library/movies
      - /home/ubuntu/data/media/tv/:/library/tv
      - /tmp/:/tmp/unmanic
    restart: unless-stopped" >> docker_apps/unmanic/docker-compose.yml

echo "version: '3.1'
services:
  uptime-kuma:
    image: louislam/uptime-kuma:1
    container_name: uptime_kuma
    volumes:
      - /home/ubuntu/docker_apps/uptime_kuma/data:/app/data
    #ports:
    #  - 3001:3001
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true" >> docker_apps/uptime_kuma/docker-compose.yml

echo "version: "2.1"
services:
  wireguard:
    image: lscr.io/linuxserver/wireguard
    container_name: wireguard
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PUID=<PUID>
      - PGID=<PGID>
      - TZ=Asia/Kolkata
      - SERVERURL=<Enter URL> #optional
      - SERVERPORT=51820 #optional
      - PEERS=1 #optional
      - PEERDNS=auto #optional
      - INTERNAL_SUBNET=10.13.13.0 #optional
      - ALLOWEDIPS=0.0.0.0/0 #optional
    volumes:
      - /home/ubuntu/docker_apps/wireguard/config:/config
      - /lib/modules:/lib/modules
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped" >> docker_apps/wireguard/docker-compose.yml