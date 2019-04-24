# Deploy kubevirt 

## Intro


## Lab

First we create the security context constraint and then deploy the kubevirt operator.
```
oc adm policy add-scc-to-user privileged -n kubevirt -z kubevirt-operator
oc create -f chimera-kubevirt/kubevirt-operator.yaml
```
Check the pods are up and running:

```
watch oc get pods -n kubevirt
```

So now that kubevirt is up and running, we need to get the UI operator deployed as well.
```
oc new-project kubevirt-web-ui
oc project
cd /root/go/src/github.com/kubevirt/web-ui-operator/deploy
oc apply -f service_account.yaml
oc apply -f role.yaml
oc apply -f role_binding.yaml
oc apply -f crds/kubevirt_v1alpha1_kwebui_crd.yaml
oc apply -f operator.yaml
oc apply -f crds/kubevirt_v1alpha1_kwebui_cr.yaml
```

Wait for the pod creation to finish, watch it using
```
watch oc get pods -n kubevirt-web-ui
```

In order to create a VM from a local image, we need to deploy CDI (containerized data importer) so that we can use PVCs as disks for VMs.
CDI supports .img, .iso and .qcow2 images.

```
oc create -f cdi-controller.yaml
```


Once they are all up, check the webfrontend running on port 9000

TODO: Add the kubevirt git cloning to the prep section
      git clone https://github.com/kubevirt/web-ui-operator.git
      Add the virtctl download as well (make sure the version matches kubevirt!)
      wget https://github.com/kubevirt/kubevirt/releases/download/v0.15.0/virtctl-v0.15.0-linux-amd64
