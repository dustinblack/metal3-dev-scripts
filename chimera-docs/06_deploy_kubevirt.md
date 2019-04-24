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
cd ~/web-ui-operator/deploy
oc apply -f service_account.yaml
oc apply -f role.yaml
oc apply -f role_binding.yaml
oc apply -f crds/kubevirt_v1alpha1_kwebui_crd.yaml
oc apply -f operator.yaml
oc apply -f crds/kubevirt_v1alpha1_kwebui_cr.yaml
```

Wait for the pod creation to finish, watch it using
```
watch oc get pods -n kubevirt
```

Once they are all up, check the webfrontend running on port 9000

TODO: Add the kubevirt git cloning to the prep section
      Add the virtctl download as well
