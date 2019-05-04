#!/usr/bin/env bash
set -ex

source logging.sh

tuned-adm profile virtual-host
yum -y groupinstall 'Virtualization Host'
systemctl enable libvirtd; systemctl start libvirtd
yum -y install git vim-enhanced epel-release

yum -y install nginx
WEBHOME=/opt/dev-scripts/html
mkdir -p $WEBHOME
chmod 755 $WEBHOME
echo 'demo' > ${WEBHOME}/index.html
sed -i 's/80\ default_server/88\ default_server/g' /etc/nginx/nginx.conf
sed -i 's/\/usr\/share\/nginx\/html/\/opt\/dev-scripts\/html/g' /etc/nginx/nginx.conf
systemctl enable nginx
systemctl restart nginx
firewall-cmd --add-port 88/tcp
firewall-cmd --add-port 88/tcp --permanent
