#!/bin/bash
# Ask the user for their name

# descarga antes de correr
# curl -s https://raw.githubusercontent.com/bmya/odoo-docker-scripts/master/install.sh | bash

# contenido de .sh

before_reboot(){
	curl -s https://raw.githubusercontent.com/bmya/odoo-docker-scripts/master/createodoo.sql
	sudo mkdir -p /opt/database
	sudo mkdir -p /opt/odoo/.filelocal
	sudo mkdir -p /var/log/postgresql
	sudo mkdir -p /opt/odoo/conf
	sudo mkdir -p /opt/odoo/extra-addons
	sudo mkdir -p /opt/nginx
	sudo wget -qO- https://get.docker.com/ | sh
	sudo gpasswd -a ${USER} docker
	sudo chown -R ${USER}:${USER} /opt
}

after_reboot(){
	docker run -d --restart="always" --name="postgres" \
	-v /opt/database:/var/lib/postgresql/data \
	-v /var/log/postgresql:/var/log/postgresql postgres:9.4
	cat createodoo.sql | docker exec -i postgres psql -Upostgres
	curl -s https://raw.githubusercontent.com/bmya/odoo-docker-scripts/master/createodoo.sql | docker exec -i postgres psql -Upostgres
	cd /opt/odoo
	curl -O https://raw.githubusercontent.com/bmya/odoo-docker-scripts/master/doeall
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
}

if [ -f /var/run/rebooting-for-updates ]; then
    after_reboot
    sudo rm /var/run/rebooting-for-updates
    sudo update-rc.d myupdate remove
else
    before_reboot
    sudo touch /var/run/rebooting-for-updates
    sudo update-rc.d myupdate defaults
    sudo reboot
fi
