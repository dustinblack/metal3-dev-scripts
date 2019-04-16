#!/bin/bash

yum -y groupinstall 'Virtualization Host'
systemctl enable libvirtd; systemctl start libvirtd
yum -y install git vim-enhanced
cd ~
git clone https://github.com/dustinblack/metalshift-chimera
cd metalshift-chimera
./01_install_requirements.sh
./02_configure_host.sh
./03_ocp_repo_sync.sh
./04_CHIMERA_prep_ironic.sh

