#!/bin/bash

yum -y groupinstall 'Virtualization Host'
systemctl enable libvirtd; systemctl start libvirtd
yum -y install git vim-enhanced
