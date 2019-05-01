# Lab 5: VM and Container Workloads

<img src="https://upload.wikimedia.org/wikipedia/sco/thumb/6/6c/RedHat.svg/1280px-RedHat.svg.png" alt="Red Hat Logo" height="200px"><img src="http://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE2qVsJ?ver=3f74" alt="Microsoft Logo" height="200px">

## Create Persistent Volume Claim

In the web console, navigate to _'Storage > Persistent Volume Claims'_ and click on the _Create Persistent Volume Claim_ button. Select _rook-ceph-block_ under _Storage Class_, and use _mssql_ as your _Persistent Volume Claim Name_. For _Access Mode_ select _Single User (RWO)_ and for _Size_ input _200 Gi_, then click the _Create_ button.

## Create the MS SQL Server Pod

> Note/TODO: RH Registry secret should already be in place

In the web console, navigate to _'Workloads > Pods'_. In the _Project_ drop-down select _default_ and then click on the _Create Pod_ button.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mssqlonrhel
  namespace: default
spec:
  volumes:
    - name: mssqlps
      persistentVolumeClaim:
        claimName: mssql
  containers:
    - name: sql
      image: mcr.microsoft.com/mssql/rhel/server:2019-CTP2.1
      env:
      - name: ACCEPT_EULA
        value: 'Y'
      - name: MSSQL_SA_PASSWORD
        value: WickedStrongPassw0rd
      ports:
      - containerPort: 1433
        name: sql
      - containerPort: 3389
        name: rdp
      volumeMounts:
        - mountPath: /var/opt/mssql/
          name: mssqlps
  imagePullSecrets:
    - name: rhsecret
```

After the pod starts, navigate to its _Terminal_ tab.

Show that this is RHEL:
```
cat /etc/redhat-release
```

Confirm our SQL Server password:
```
echo $MSSQL_SA_PASSWORD
```

Connect to the database console:
```
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'WickedStrongPassw0rd'
```

What are we running on RHEL?
```
SELECT @@version
GO
```

Create a demo database:
```
CREATE DATABASE DemoDB
GO
```

Confirm our new database:
```
SELECT Name from sys.Databases
GO
```

Back on our deployment host system, let's take a look at our Ceph storage consumption
```
TOOLBOX=$(oc get pods -l app=rook-ceph-tools -n rook-ceph | grep -v NAME | awk '{print $1}')
oc exec -n rook-ceph $TOOLBOX -- ceph -s
oc exec -n rook-ceph $TOOLBOX -- ceph df
``` 

In the Kubevirt web UI, navigate to _Workloads > Virtual Machines_, click on _Create Virtual Machine_ and then _Create with Wizard_. Name the new VM _win2012_, select _Cloned Disk_ for the _Provision Source_, select _Microsoft Windows Server 2012 R2_ for the _Operating System_, select _medium_ for the _Flavor_, and select _generic_ for the _Workload Profile_, then click the _Next_ button.

A _nic0_ should already be populated for the networking, so click the _Next_ button on this screen. On the _Storage_ screen, click the _Attach Disk_ button and select the _windows-2012-datavolume_ from the drop-down list. Click the blue check box, then click the _Create Virtual Machine_ button.

Back in the _Virtual Machines_ view, click the menu button to the right of the _win2012_ virtual machine, and then click _Start Virtual Machine_.

When the _win2012_ virtual machine completes initializing and starting up, click on its _Consoles_ tab and login to Windows with the _Administrator_ username and _RedHat1!_ password. Open the _HammerDB_ link on the desktop.
