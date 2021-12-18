# Wordpress, MySQL, phpMyAdmin, Traefik (TLS, HTTPS), Docker

```bash
sudo systemctl daemon-reload  # Reload systemd after service changing.
clear; sudo systemctl status *4sou*timer  # Check backup timers

sudo systemctl start 4soulsband_wordpress_daily_backup.service  # Start the backup manually.

journalctl -u 4soulsband_wordpress_daily_backup.timer
journalctl -u 4soulsband_wordpress_daily_backup.service


```

## Tested
- 2021-12-01

## Requirements
- Oracle VPS Free Tier ARM (VM.Standard.A1.Flex)
- Ubuntu 20.04 ARM

## Version
- Zabbix 5.0.16
- Postgres 12
- Grafana 8.2.0
- Traefik 2.5.3

## Clone the repository
```bash
cd ~ &&
git clone https://github.com/anklav24/zabbix-docker &&
cd zabbix-docker
```

## Select a develop branch (Optional)
```bash
git checkout develop
```

## Check ```deploy_configs``` and ```*-docker-compose.yaml```
Replace domains, envs, emails, logins, passwords and tls.certresolver on yours!

## Install
Docker, Docker-compose and other stuff.
```bash
chmod +x install.sh && ./install.sh
```

## Run compose files
For a split config, use one of these two commands on the two servers:
```bash
cd ~/zabbix-docker
```
```bash
docker-compose -f zabbix-server-docker-compose.yaml up -d

docker-compose -f zabbix-web-docker-compose.yaml up -d
```
If you have one powerfull VPS use:
```bash
docker-compose up -d
```


## Zabbix
- Check deploy_configs/env_vars/zabbix_agent.env

##Traefik
- Check .env, deploy_configs/traefik

### UI Links
- https://xn--4-htbm7bza.xn--p1ai/
- https://traefik.oracle24.duckdns.org
- https://portainer.oracle24.duckdns.org
- https://pgadmin.oracle24.duckdns.org
- https://phpmyadmin.oracle24.duckdns.org
- https://zabbix.zabbix-web24.duckdns.org

### References
- https://www.duckdns.org/
- https://ssllabs.com/ssltest
- https://hstspreload.org/
- https://doc.traefik.io/traefik/
- https://grafana.com/tutorials/run-grafana-behind-a-proxy/
- https://github.com/muutech/zabbix-templates/tree/master/ANDROID
- https://play.google.com/store/apps/details?id=fr.damongeot.zabbixagent&hl=ru&gl=US
- https://www.zabbix.com/documentation/5.0/ru/manual/encryption/using_pre_shared_keys
- https://www.zabbix.com/documentation/5.0/manual/config/items/itemtypes/zabbix_agent/win_keys

## Troubleshooting:
If a wordpress site has the "gateway timeout" error, try add this to container labels:
```yaml
- traefik.docker.network=traefik_proxy_net
```

## Redis
```bash
docker exec -ti redis redis-cli -p 6380 monitor

docker exec -ti redis redis-cli -p 6380
127.0.0.1:6379> KEYS *
```

```bash
# Create a backup of wordpress
tar -czvf 4soulsband_wordpress1_backup_`date +%Y-%m-%d"T"%H%M`00.tar.gz 4soulsband_wordpress1  # Wordpress files backup
docker exec 4soulsband_mysql_db1 mysqldump --no-tablespaces -u exampleuser --password=examplepass 4soulsband | gzip -9 > 4soulsband_mysql_backup1_`date +%Y-%m-%d"T"%H%M`00.sql.gz  # Wordpress DB backup
```

## Backup and restore
### Create a backup of wordpress
```bash
# Create a backup of wordpress
tar -czvf 4soulsband_wordpress_backup_`date +%Y-%m-%d"T"%H%M`.tar.gz 4soulsband_wordpress  # Wordpress files backup
docker exec 4soulsband_mysql_db mysqldump --no-tablespaces -u exampleuser --password=examplepass 4soulsband | gzip -9 > 4soulsband_mysql_backup_`date +%Y-%m-%d"T"%H%M`.sql.gz  # Wordpress DB backup
```

## Restore from copy backup
### Drop DB
```bash
docker exec -ti 4soulsband_mysql_db mysql -u exampleuser --password=examplepass 4soulsband
```
```sql
DROP TABLE `wp_commentmeta`, `wp_comments`, `wp_links`, `wp_options`, `wp_postmeta`, `wp_posts`,`wp_termmeta`, `wp_terms`, `wp_term_relationships`, `wp_term_taxonomy`, `wp_usermeta`, `wp_users`;
exit
```
### Restore DB
```bash
# Example
gunzip < mysql_backup_13-12-2021T115500.sql.gz | docker exec -i 4soulsband_mysql_db mysql -u exampleuser --password=examplepass 4soulsband
```

### Restore files
```bash
sudo rm -rfv 4soulsband_wordpress/
sudo tar -xzvf 4soulsband_wordpress_backup_2021-12-13T123400.tar.gz
./down_up.sh  # Restart docker containers

# If the above does not work. Try this.
sudo chmod 755 4soulsband_wordpress
sudo find ./4soulsband_wordpress/ -type d -exec chmod -v 755 {} +
sudo find ./4soulsband_wordpress/ -type f -exec chmod -v 644 {} +
sudo chown -Rv www-data:www-data 4soulsband_wordpress
./down_up.sh  # Restart docker containers

sudo tree 4soulsband_wordpress/wp-content/ -dpugL 3  # Show directories tree
sudo tree 4soulsband_wordpress/wp-content/ -pugL 4  # Show all files tree
```
