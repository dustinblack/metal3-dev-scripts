# Deploy kubevirt 

## Intro


## Lab

First we create the security context constraint and then deploy the kubevirt operator.
```
oc adm policy add-scc-to-user privileged -n kubevirt -z kubevirt-operator
oc create -f chimera-kubevirt/kubevirt-operator.yaml
```
