# Workloads

<img src="https://upload.wikimedia.org/wikipedia/sco/thumb/6/6c/RedHat.svg/1280px-RedHat.svg.png" alt="Red Hat Logo" height="200px"><img src="http://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE2qVsJ?ver=3f74" alt="Microsoft Logo" height="200px">

## Create Persistent Volume Claim

In the web console, navigate to _'Storage > Persistent Volume Claims'_ and click on the _Create Persistent Volume Claim_ button. Select _rook-ceph-block_ under _Storage Class_, and use _mssql_ as your _Persistent Volume Claim Name_. For _Access Mode_ select _Single User (RWO)_ and for _Size_ input _100 Gi_, then click the _Create_ button.

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
        value: Wicked$trongPassw0rd
      ports:
      - containerPort: 1433
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
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Wicked$trongPassw0rd'
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
TOOLBOX=$(oc get pods -l app=rook-ceph-tools -n openshift-storage | grep -v NAME | awk '{print $1}')
oc exec -n openshift-storage $TOOLBOX -- ceph -s
oc exec -n openshift-storage $TOOLBOX -- ceph df
``` 
