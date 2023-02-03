# Folders using `folderName`

You can mount only sub-folders of NFS fileshare to your containers.

Here are the main steps:

1. Create storage account and NFS fileshare
2. Create required sub-folders to the fileshare
3. Create PV with `folderName` to map to sub-folder

Here is example yaml:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
  namespace: demos
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  csi:
    driver: file.csi.azure.com
    # <clipped>
    volumeAttributes:
      storageAccount: <storage>
      folderName: app1 # <- sub-folder in fileshare
      shareName: nfs
      protocol: nfs
```

You might get following error if `app1` folder does not exist, when you deploy your application:

`kubectl describe pod -n demo`

```
Events:
  Type     Reason       Age                  From               Message
  ----     ------       ----                 ----               -------
  Normal   Scheduled    5m3s                 default-scheduler  Successfully assigned demos/webapp-fs-tester-demo-64c544d866-b6mm6 to aks-nodepool1-30984766-vmss000000
  Warning  FailedMount  81s (x9 over 4m51s)  kubelet            MountVolume.MountDevice failed for volume "nfs-pv" : rpc error: code = Internal desc = volume(nfspv) mount <storage>.file.core.windows.net:/<storage>/nfs/app1 on /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/f57d30ba19d70a88ef089c06dc4b665858b58a5df6b88e94d84912db30d967c8/globalmount failed with mount failed: exit status 32
Mounting command: mount
Mounting arguments: -t nfs -o vers=4,minorversion=1,sec=sys <storage>.file.core.windows.net:/<storage>/nfs/app1 /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/f57d30ba19d70a88ef089c06dc4b665858b58a5df6b88e94d84912db30d967c8/globalmount
Output: mount.nfs: rpc.statd is not running but is required for remote locking.
mount.nfs: Either use '-o nolock' to keep locks local, or start statd.
  Warning  FailedMount  41s (x2 over 3m)  kubelet  Unable to attach or mount volumes: unmounted volumes=[nfs], unattached volumes=[nfs kube-api-access-wmc9s]: timed out waiting for the condition
```

After you connect to that fileshare using e.g., Linux VM:

```bash
azureuser@vm:~$ sudo apt-get -y update
azureuser@vm:~$ sudo apt-get install nfs-common
azureuser@vm:~$ sudo mkdir -p /mnt/nfs
azureuser@vm:~$ sudo mount -t nfs <storage>.file.core.windows.net:/<storage>/nfs /mnt/nfs -o vers=4,minorversion=1,sec=sys
azureuser@vm:~$ mount
/dev/sda1 on / type ext4 (rw,relatime,discard)
# <clipped>
<storage>10.file.core.windows.net:/<storage>/nfs on /mnt/nfs type nfs4 (rw,relatime,vers=4.1,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.2.0.53,local_lock=none,addr=10.3.0.4)
```

Create sub-folders to the fileshare:

```bash
azureuser@vm:$ cd /mnt/nfs
azureuser@vm:/mnt/nfs$ mkdir app1
azureuser@vm:/mnt/nfs$ mkdir app2
```

If you now re-deploy your application to AKS and and verify:

`kubectl describe pod -n demo`

```
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  4m10s  deployment-controller  Scaled up replica set webapp-fs-tester-demo-64c544d866 to 1
```

You can generate files to the fileshare e.g.,

```bash
cat <<EOF > payload.json
{
  "path": "/mnt/nfs",
  "folders": 2,
  "subFolders": 2,
  "filesPerFolder": 3,
  "fileSize": 1024
}
EOF

curl --no-progress-meter -X POST --data @payload.json -H "Content-Type: application/json" "http://$ingress_ip/api/generate" | jq .

# Output:
{
  "server": "webapp-fs-tester-demo-64b6cbbfd7-6fbm2",
  "path": "/mnt/nfs",
  "filesCreated": 12,
  "milliseconds": 238.7466
}
```

To see listed files:

```
curl --no-progress-meter -X POST --data '{"path": "/mnt/nfs","filter": "*.*","recursive": true}' -H "Content-Type: application/json" "http://$ingress_ip/api/files" | jq .
{
  "server": "webapp-fs-tester-demo-64b6cbbfd7-6fbm2",
  "files": [
    "/mnt/nfs/2/2/3.txt",
    "/mnt/nfs/2/2/2.txt",
    "/mnt/nfs/2/2/1.txt",
    "/mnt/nfs/2/1/3.txt",
    "/mnt/nfs/2/1/2.txt",
    "/mnt/nfs/2/1/1.txt",
    "/mnt/nfs/1/2/3.txt",
    "/mnt/nfs/1/2/2.txt",
    "/mnt/nfs/1/2/1.txt",
    "/mnt/nfs/1/1/3.txt",
    "/mnt/nfs/1/1/2.txt",
    "/mnt/nfs/1/1/1.txt"
  ],
  "milliseconds": 25.5948
}
```

If you now return to the Linux VM and execute `tree` in `app1` folder:

```bash
azureuser@vm:/mnt/nfs/app1$ tree
.
├── 1
│   ├── 1
│   │   ├── 1.txt
│   │   ├── 2.txt
│   │   └── 3.txt
│   └── 2
│       ├── 1.txt
│       ├── 2.txt
│       └── 3.txt
└── 2
    ├── 1
    │   ├── 1.txt
    │   ├── 2.txt
    │   └── 3.txt
    └── 2
        ├── 1.txt
        ├── 2.txt
        └── 3.txt

6 directories, 12 files
azureuser@vm:/mnt/nfs/app1$
```
