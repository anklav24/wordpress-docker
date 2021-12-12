# Wordpress, MySQL, phpMyAdmin, Traefik (TLS, HTTPS), Docker

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

### Grafana
- PostgeSQL
  - Configuration
    - Configuration - Data sources - Add data source - PostgreSQL
    - Host: postgres-server or zabbix-server24.duckdns.org:5432
    - Database: zabbix
    - User: zabbix
    - TLS/SSL Mode: disable
    - Version: 12+
  - Verify that you connect
    - Go to Explore and do some queries

- Zabbix plugin
  - Configuration - Plugins - Zabbix - Config - Enable
  - Configuration - Data sources - Add data source - Zabbix
  - Default - On
  - URL: http://zabbix-web-nginx-pgsql:8080/api_jsonrpc.php
  - Username: Admin  (Capital A)
  - Password: zabbix
  - Direct DB Connection - PostgreSQL (Optional)
  - Configuration - Data sources - Add data source - Zabbix - Dashboards - Add defaults (Optional)
  - Click Plus button - Create - Dashboard - Add an empty panel - Add new metrics - Applye
  - Adjust - Refresh Time

## Zabbix
### Android Active Agent
- [Android Zabbix Active Agent](https://play.google.com/store/apps/details?id=fr.damongeot.zabbixagent&hl=ru&gl=US)
- [Template](https://github.com/muutech/zabbix-templates/tree/master/ANDROID)
- Add autoregistration actions in Zabbix-Server
- Enable discovery(?)
 
### Windows Passive/Active agents with TLS
- Generate and save ```C:\Program Files\Zabbix Agent\zabbix_agentd.psk```
  ```bash
  openssl rand -hex 32
  ```
- Add into ```C:\Program Files\Zabbix Agent\zabbix_agentd.conf```
  ```bash
  TLSConnect=psk
  TLSAccept=psk
  TLSPSKFile=C:\Program Files\Zabbix Agent\zabbix_agentd.psk
  TLSPSKIdentity=NZXT-HOME-PC
  ```
- Restart the agent service from the task manager

### Mikrotik SNMP
- Enable SNMP and add corresponding IP's

### UI Links
Traefik
- https://traefik.zabbix-web24.duckdns.org
- https://zabbix.zabbix-web24.duckdns.org
- https://grafana.zabbix-web24.duckdns.org
- https://mikrotik.zabbix-web24.duckdns.org

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

### Troubleshooting:
If a wordpress site has the "gateway timeout" error, try add this to container labels:
```yaml
- traefik.docker.network=traefik_proxy_net
```

```bash
docker exec -ti redis redis-cli -p 6380 monitor

docker exec -ti redis redis-cli -p 6380
127.0.0.1:6379> KEYS *
```

# Restore from wordpress backup
```bash
docker exec -ti 4soulsband_mysql_db mysql -u exampleuser --password=examplepass 4soulsband
```
```sql
DROP TABLE `wp_commentmeta`, `wp_comments`, `wp_links`, `wp_options`, `wp_postmeta`, `wp_posts`,`wp_termmeta`, `wp_terms`, `wp_term_relationships`, `wp_term_taxonomy`, `wp_usermeta`, `wp_users`;
exit
```

```bash
sudo rm -rfv 4soulsband_wordpress/
./down_up.sh  # Return docker containers
cat dump-ck03767_4souls-full-26.12.2020-10.sql | docker exec -i 4soulsband_mysql_db mysql -u exampleuser --password=examplepass 4soulsband
# Run site /wp-admin

sudo cp -rv 4souls/wp-content 4soulsband_wordpress/
sudo find ./4soulsband_wordpress/wp-content -type d -exec chmod -v 744 {} +
sudo find ./4soulsband_wordpress/wp-content -type f -exec chmod -v 644 {} +
sudo chown -Rv www-data:www-data 4soulsband_wordpress/wp-content/*

sudo tree 4soulsband_wordpress/wp-content/ -dpugL 3  # Show directories tree
sudo tree 4soulsband_wordpress/wp-content/ -pugL 4  # Show all files tree
```

Cactus Companion
Visual Composer Website Builder
