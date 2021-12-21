# Wordpress, MySQL, Redis phpMyAdmin, Traefik (TLS, HTTPS), Docker, Uploading to Google Drive

## Overview
If you need your own Wordpress server with SSL and Backups.

### Requirements
- Oracle VPS Free Tier ARM (VM.Standard.A1.Flex)
- Ubuntu 20.04 ARM

### Version
- docker-compose version 2.4
- wordpress:php8.0
- redis 6.0.15-alpine
- Zabbix agent 5.0.16
- Postgres 12
- Traefik 2.5.3
- Portainer 2.9.3-alpine
- phpmyadmin 5.1.1
- pgadmin 4.6.2
- mysql-server:8.0 (Oracle)

### Tested
- 2021-12-21

# Installation
### Clone the repository
```bash
cd ~ &&
git clone https://github.com/anklav24/wordpress-docker &&
cd wordpress-docker
```

### Select a develop branch (Optional)
```bash
git checkout develop
```

### Rename ```deploy_configs_example```, ```.env.example```
- ```deploy_configs_example``` -> ```deploy_configs```
- ```.env.example``` -> ```.env```

### Check ```deploy_configs```, ```*-docker-compose.yaml```, ```.env```
Replace domains, envs, emails, logins, passwords and tls.certresolver on yours!
Don't use examples in production!

### Install Docker, Docker-compose and other stuff.
```bash
chmod +x install.sh && ./install.sh
```
### Install gdrive as root user
- https://github.com/prasmussen/gdrive

### After install go to check your wordpress domain
- [https://YOUR-WORDPRESS-DOMAIN.com]()
- Setup wordpress and install ```redis-object-cache``` plugin

### Run compose files
```bash
cd ~/wordpress-docker
docker-compose -f 1-docker-compose.yaml up -d; 
docker-compose -f 2-docker-compose.yaml up -d
```

## UI Links
- https://xn--4-htbm7bza.xn--p1ai/
- https://traefik.oracle24.duckdns.org
- https://portainer.oracle24.duckdns.org (Restricted by IP with Traefik)
- https://pgadmin.oracle24.duckdns.org (Restricted by IP with Traefik)
- https://phpmyadmin.oracle24.duckdns.org (Restricted by IP with Traefik)
- https://zabbix.zabbix-web24.duckdns.org (Restricted by IP with Traefik)

## References
- https://www.duckdns.org/
- https://ssllabs.com/ssltest
- https://hstspreload.org/
- https://doc.traefik.io/traefik/
- https://github.com/prasmussen/gdrive
- https://docs.docker.com/compose/compose-file/compose-file-v2/

## Troubleshooting:
If a wordpress site has the "gateway timeout" error, you need to set default network for traefik:
```yaml
- traefik.docker.network=traefik_proxy_net
```

## Useful commands
### Redis
```bash
docker exec -ti redis redis-cli -p 6380 monitor

docker exec -ti redis redis-cli -p 6380
127.0.0.1:6379> KEYS *
```

### Systemd service
Set up backup automation:
```
sudo cp systemd_services/* /etc/systemd/system/  # Copy services and timers files.
sudo systemctl start 4soulsband_wordpress_montly_backup.service  # Check the service works properly (Example)
sudo systemctl enable 4soulsband_wordpress_montly_backup.timer  # Enable a timer (Example)
```
```bash
sudo systemctl daemon-reload  # Reload systemd after service changing.
clear; sudo systemctl status *4sou*timer  # Check backup timers
sudo systemctl list-timers  # Check all timers

sudo systemctl start 4soulsband_wordpress_daily_backup.service  # Start the backup manually.
sudo systemctl start 4soulsband_wordpress_weekly_backup.service  # Start the backup manually.
sudo systemctl start 4soulsband_wordpress_yearly_backup.service  # Start the backup manually. With Google Drive Sync

journalctl -u 4soulsband_wordpress_daily_backup.timer  # Check logs
journalctl -u 4soulsband_wordpress_daily_backup.service  # Check logs
```

## Backup and restore
### Backup
```bash
# Example
./4soulsband_wordpress_backup.sh daily 7 YOUR_DATABASE_NAME YOUR_DATABASE_USER YOUR_DATABASE_PASSWORD true
# Need args: task_name (daily, monthly, yearly), days_to_keep (7, 186, 1825), mysql_db_name, mysql_user, mysql_password, [debug (true)]
```
### Restore
```bash
# Before you need change timestamp and backup_dir_name variables in the file 
./4soulsband_wordpress_restore.sh daily YOUR_DATABASE_NAME YOUR_DATABASE_USER YOUR_DATABASE_PASSWORD true
# Need args: task_name (daily, monthly, yearly), mysql_db_name, mysql_user, mysql_password, [debug (true)]
```
