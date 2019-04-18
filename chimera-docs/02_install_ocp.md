# Install OCP

## Create the cluster

```
./06_CHIMERA_create_cluster.sh
```

Note: This script now refers to its own version of common.sh, named common_chimera.sh. That way we do not need internet connectivity for this step anymore. The latest version of the images is determined throught the symbolic link .latest in /opt/dev-scripts/ironic/html/images instead of pulling it. This happens in ocp_CHIMERA_install_env.sh



