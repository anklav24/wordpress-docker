#!/usr/bin/env bash

docker-compose -f 1-docker-compose.yaml down
docker-compose -f 2-docker-compose.yaml down
echo

docker-compose -f 1-docker-compose.yaml up -d
docker-compose -f 2-docker-compose.yaml up -d
echo

#docker logs -f 4soulsband_backup

#ctop
#sleep 3
#docker exec -ti 4soulsband_wordpress cat /etc/hosts
#echo
#
#sleep 3
#docker exec -ti 4soulsband_wordpress apachectl configtest
#echo
#
#sleep 3
#docker exec -ti traefik tail -n 100 -f /var/log/traefik/traefik.log
