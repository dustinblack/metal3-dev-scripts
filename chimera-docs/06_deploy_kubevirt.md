# Deploy kubevirt 

<img src="https://kubevirt.io/user-guide/docs/latest/_images/KubeVirt_icon.png" alt="Kubevirt Logo" height="200px">

## Intro


## Lab

In a separate terminal, setup a watch of the pods we will create.
```
watch 'oc get pods --all-namespaces |grep  kubevirt'
```

First we create the security context constraint and then deploy the kubevirt operator.
```
oc adm policy add-scc-to-user privileged -n kubevirt -z kubevirt-operator
oc apply -f chimera-kubevirt/kubevirt-operator.yaml
oc apply -f chimera-kubevirt/kubevirt-cr.yaml
```

Now in our separate terminal we'll watch the web UI components.
```
watch oc get pods -n kubevirt-web-ui
```

With kubevirt up and running, we need to get the UI operator deployed as well.
```
oc new-project kubevirt-web-ui
WEBUIPATH=/root/go/src/github.com/kubevirt/web-ui-operator/deploy
ls $WEBUIPATH
oc apply -f ${WEBUIPATH}/crds/kubevirt_v1alpha1_kwebui_crd.yaml
oc apply -f ${WEBUIPATH}/crds/kubevirt_v1alpha1_kwebui_cr.yaml
oc apply -f $WEBUIPATH
```
Once the pods are all up, check the webfrontend running on port 9000

## Spin up a fedora VM

To run a fedora VM we need a PVC for it so we can provide ceph-based storage to it:
```
oc apply -f chimera-kubevirt/fedora-pvc.yaml
oc apply -f chimera-kubevirt/fedora-vm.yaml
```
Watch the VM being spun up:
```
watch oc get vmis
```


In order to create a VM from a local image, we need to deploy CDI (containerized data importer) so that we can use PVCs as disks for VMs.
CDI supports .img, .iso and .qcow2 images.

```
oc apply -f cdi-controller.yaml
```



TODO: Add the kubevirt git cloning to the prep section
      git clone https://github.com/kubevirt/web-ui-operator.git
      Add the virtctl download as well (make sure the version matches kubevirt!)
      wget https://github.com/kubevirt/kubevirt/releases/download/v0.15.0/virtctl-v0.15.0-linux-amd64
