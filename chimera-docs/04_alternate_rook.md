<img src="https://landscape.cncf.io/logos/rook.svg" alt="Rook Logo" height="200px"><img src="https://ceph.com/wp-content/uploads/2016/07/Ceph_Logo_Stacked_RGB_120411_fa.png" alt="Ceph Logo" width="200px">

## Intro

[Rook.io](https://rook.io/) is a Kubernetes [operator](https://coreos.com/operators/) that orchestrates software-defined storage deployment and management for container persistent storage. We use rook.io initially to deploy [Ceph](https://ceph.com/) as a set of containerized services. Then we define a storage class, which the operator will "listen" to in order to automate the provisioning of Ceph volumes to fulfill persistent volume claims.


## Lab

Login to the cluster
```
export KUBECONFIG=/root/metalshift-chimera/ocp/auth/kubeconfig
oc login -u system:admin
```

In a separate terminal, let's setup a watch of the pods we'll create.
```
watch 'oc get pods --all-namespaces | grep rook'
```

Run the deploy script 10_deploy_rook.sh:
```
./10_deploy_rook.sh
```

The operator will respond to the cluster request by inventorying the environment, standing up the three requested Ceph mons and the Ceph manager, and then preparing and standing up the three Ceph OSDs. Our nodes are each configured with NVMe SSDs that will be used as the OSD devices.


Now let's use the toolbox to watch the Ceph status while everything comes up.
```
export TOOLBOX=$(oc get pods -l app=rook-ceph-tools -n openshift-storage | grep -v NAME | awk '{print $1}')
watch 'oc exec -n openshift-storage $TOOLBOX -- ceph -s'
```

It's also interesting to look at the osd tree once everything is up.
```
oc exec -n openshift-storage $TOOLBOX -- ceph osd tree
```

The corresponding storage class has been created through the script. It will be used by the rook.io operator to orchestrate the storage provisioning.
``` 
oc get sc
```

Looking again at the `ceph -s` output, we can now see that a pool exists with the default 100 placement groups, and we can dig a little deeper into the configuraiton.
```
oc exec -n openshift-storage $TOOLBOX -- ceph -s
oc exec -n openshift-storage $TOOLBOX -- ceph df
oc exec -n openshift-storage $TOOLBOX -- ceph osd pool get rbd all
```

We'll test out our new persisten storage by makeng a simple persistent volume claim.
```
oc apply -f chimera-rook/pvctest.yaml
oc get pvc
oc get pv
oc describe pv
```

The Ceph RBD has the same name as the OpenShift persistent volume.
```
PV=$(oc get pv | grep -v NAME | awk '{print $1}')
oc exec -n openshift-storage $TOOLBOX -- rbd ls
oc exec -n openshift-storage rook-ceph $TOOLBOX -- rbd info $PV
```

## Lab Recording
TODO

