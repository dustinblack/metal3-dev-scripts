.PHONY: default all requirements configure repo_sync ironic build ocp_run deploy_bmo register_hosts clean ocp_cleanup host_cleanup bell
default: requirements configure repo_sync ironic build ocp_run deploy_bmo register_hosts bell

chimera_prep_host:
	./00_CHIMERA_prep_host.sh

chimera_repo_sync:
	./03_CHIMERA_ocp_repo_sync.sh

chimera_ironic:
	./04_CHIMERA_prep_ironic.sh

chimera_build:
	./05_CHIMERA_build_ocp_installer.sh

chimera_lab_ready: requirements configure chimera_repo_sync chimera_ironic chimera_build

chimera_all: chimera_prep_host chimera_lab_ready

all: default

requirements:
	./01_install_requirements.sh

configure:
	./02_configure_host.sh

repo_sync:
	./ORIG_03_ocp_repo_sync.sh

ironic:
	./ORIG_04_setup_ironic.sh

build:
	./ORIG_05_build_ocp_installer.sh

ocp_run:
	./ORIG_06_create_cluster.sh

deploy_bmo:
	./08_deploy_bmo.sh

register_hosts:
	./11_register_hosts.sh

clean: ocp_cleanup host_cleanup

ocp_cleanup:
	./ocp_cleanup.sh

host_cleanup:
	./host_cleanup.sh

bell:
	@echo "Done!" $$'\a'
