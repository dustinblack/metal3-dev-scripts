#!/bin/bash

yum -y groupinstall 'Virtualization Host'
systemctl enable libvirtd; systemctl start libvirtd
yum -y install git vim-enhanced

yum -y install nginx
mkdir -p /home/html
echo 'demo' > /home/html/index.html
sed -i s/80\ default_server/88\ default_server/g /etc/nginx/nginx.conf
sed -i s/\/usr\/share\/nginx\/html/\/home\/html/g /etc/nginx/nginx.conf
systemctl enable nginx
systemctl start nginx
