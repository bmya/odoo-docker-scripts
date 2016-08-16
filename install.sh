#!/bin/bash
# Author:
# Blanco Martin y Asociados - Daniel Blanco daniel[at]blancomartin.cl
# Ask the user for their name
# descarga antes de correr
# curl -s https://raw.githubusercontent.com/bmya/odoo-docker-scripts/master/install.sh | bash
sudo mkdir -p /opt/database
sudo mkdir -p /opt/odoo/.filelocal
sudo mkdir -p /var/log/postgresql
sudo mkdir -p /opt/odoo/conf
sudo mkdir -p /opt/odoo/extra-addons
sudo mkdir -p /opt/nginx
sudo curl -s https://get.docker.com/ | bash
sudo gpasswd -a ${USER} docker
sudo chown -R ${USER}:${USER} /opt
cd /opt/nginx
curl -O https://raw.githubusercontent.com/bmya/odoo-docker-scripts/master/nginx/default.conf
echo Configuracion de nginx
echo
echo Seleciona el nombre de dominio que deseas usar:
read domain_name
echo El domino elegido es $domain_name
echo
echo Selecciona el nombre de la base de datos que deseas filtrar con el dominio:
read db_name
echo La base de datos elegida es $db_name
echo
sed -i "s/nombre_srv/"$domain_name"/" default.conf
sed -i "s/nombre_bd/"$db_name"/" default.conf

docker run -d --restart="always" --name="postgres" \
-v /opt/database:/var/lib/postgresql/data \
-v /var/log/postgresql:/var/log/postgresql postgres:9.4
curl -s https://raw.githubusercontent.com/bmya/odoo-docker-scripts/master/createodoo.sql | docker exec -i postgres psql -Upostgres
echo 'CREATE DATABASE '$db_name';GRANT ALL PRIVILEGES ON DATABASE '$db_name' TO '${USER}';' | docker exec -i postgres psql -Upostgres
cd /opt/odoo/conf
curl -O https://raw.githubusercontent.com/bmya/docker-odoo-bmya/master/openerp-server.conf
cd /opt/odoo
curl -O https://raw.githubusercontent.com/bmya/odoo-docker-scripts/master/doeall
sed -i "s/nombre_bd/"$db_name"/" doeall

echo "Instalacion principal terminada. Una vez que se reinicie el servidor corre '/opt/odoo/doeall' para levantar los servicios"
