#!/bin/bash
if [ $EUID -ne 0 ]; then
    echo "Script must be run by root."
fi
apt install -y wget
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-3+ubuntu22.04_all.deb
dpkg -i zabbix-release_6.0-3+ubuntu22.04_all.deb
apt update
sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent mysql-server
mysql -uroot -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;"
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -uroot zabbix
mysql -uroot -e "create user zabbix@localhost identified by 'password';"
mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost;"
sed -i 's/# DBPassword=/DBPassword=password/g' /etc/zabbix/zabbix_server.conf
sed -i 's/#        listen          8080;/        listen          8080;/g' /etc/zabbix/nginx.conf
sed -i 's/#        server_name     example.com;/        server_name     0.0.0.0;/g' /etc/zabbix/nginx.conf
systemctl restart zabbix-server zabbix-agent nginx php8.1-fpm
systemctl enable zabbix-server zabbix-agent nginx php8.1-fpm
