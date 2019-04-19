# Deploy Ceph via Rook.io

<img src="https://landscape.cncf.io/logos/rook.svg" alt="Rook Logo" height="200px"><img src="https://ceph.com/wp-content/uploads/2016/07/Ceph_Logo_Stacked_RGB_120411_fa.png" alt="Ceph Logo" width="200px">

## Intro

## Lab

```
chimera-rook/cleanup.sh
oc create -f chimera-rook/scc.yaml 
oc create -f chimera-rook/operator.yaml 
watch oc get pods -n rook-ceph-system
oc create -f chimera-rook/cluster.yaml 
oc create -f chimera-rook/toolbox.yaml 
watch oc get pods -n rook-ceph
TOOLBOX=$(oc get pods -l app=rook-ceph-tools -n rook-ceph | grep -v NAME | awk '{print $1}')
oc exec -n rook-ceph $TOOLBOX -- ceph -s
oc create -f chimera-rook/storageclass.yaml
oc exec -n rook-ceph $TOOLBOX -- ceph -s
oc exec -n rook-ceph $TOOLBOX -- ceph osd tree
oc exec -n rook-ceph $TOOLBOX -- ceph df
oc exec -n rook-ceph $TOOLBOX -- ceph osd pool get rbd all
oc create -f chimera-rook/pvctest.yaml
oc get pvc
oc get pv
oc describe pv
PV=$(oc get pv | grep -v NAME | awk '{print $1}')
oc exec -n rook-ceph $TOOLBOX -- rbd ls
oc exec -n rook-ceph $TOOLBOX -- rbd info $PV
oc delete -f chimera-rook/pvctest.yaml
```

## Lab Recording
[![asciicast](https://asciinema.org/a/xyRStkXotrbvnSPen3944NXn0.svg)](https://asciinema.org/a/xyRStkXotrbvnSPen3944NXn0)
