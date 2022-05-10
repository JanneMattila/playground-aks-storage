# Workload deployment updates

When planning for you workload deployment updates,
it's important to understand the constraints also from persistent
storage perspective.

If you use **Azure Disk** for your persistent storage,
then this part is crucial to understand:

> An Azure disk can only be mounted with Access mode type `ReadWriteOnce`, which makes it available to **one node** in AKS. If you need to share a persistent volume across multiple nodes, use Azure Files.

Above taken from [Dynamically create and use a persistent volume with Azure disks in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/azure-disks-dynamic-pv).

Here are some tests to help you plan your application setup. 
Please note that below results have been achieved with *very* **very** limited testing.
Your mileage *will* vary.

| Scenario                                                                     | Result                                                                                                                                                           |
| ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Single node & `RollingUpdate`                                                | Downtime fraction of second or not observed                                                                                                                      |
| Single node & `Recreate`                                                     | 10 seconds ± 5 seconds                                                                                                                                           |
| Two nodes & `RollingUpdate` & Workload stays in same node                    | Downtime fraction of second or not observed                                                                                                                      |
| Two nodes & `Deployment` & `RollingUpdate` & Workload moved to another node  | Deployment stuck to `Unable to attach or mount volumes`                                                                                                          |
| Two nodes & `Deployment` & `Recreate` & Workload moved to another node       | 45 seconds ± 10 seconds                                                                                                                                          |
| Two nodes & `StatefulSet` & `RollingUpdate` & Workload moved to another node | 45 seconds ± 10 seconds                                                                                                                                          |
| Two nodes & Node failure                                                     | ~8 minutes (see [workaround](https://github.com/kubernetes-sigs/azuredisk-csi-driver/tree/master/docs/known-issues/node-shutdown-recovery) to get to ~2 minutes) |

If you need to support `ReadWriteMany` to better manage the updates, then look for other storage options e.g., Azure Files or Azure NetApp Files.

## Azure Disk

Here are some of the tests logs to better understand how testing has been done.

Note: Below are examples without `Availability Zones`.

Note: Using [deployment monitor script](https://github.com/JanneMattila/webapp-update/blob/main/doc/deployment-monitor.ps1) for invoking the test endpoint of the application. Deployed test application was [webapp-update](https://github.com/JanneMattila/webapp-update) available in [Docker Hub](https://hub.docker.com/r/jannemattila/webapp-update).

Switch to different node has been enforced using `kubectl cordon` e.g., `kubectl cordon aks-nodepool1-10842753-vmss000001` commands.

### Single node

Note: You can use both [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
and [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/),
since this is single node deployment.

#### RollingUpdate

Using update strategy `RollingUpdate`:

```powershell
05/06/2022 07:46:10: 00:00:00.0043771

machineName          : webapp-fs-tester-demo-7f94d9db-2c57s
started              : 6.5.2022 4.40.56
uptime               : 00:05:14.5912097
appEnvironment       :
appEnvironmentSticky :
content              : 1.0.8


05/06/2022 07:46:30: 00:00:19.7609413
machineName          : webapp-fs-tester-demo-599dbcfb5-c2xdx
started              : 6.5.2022 4.46.29
uptime               : 00:00:02.0174074
appEnvironment       :
appEnvironmentSticky :
content              : 1.0.9


05/06/2022 07:46:54: 00:00:23.1092401
machineName          : webapp-fs-tester-demo-7f94d9db-9wwtr
started              : 6.5.2022 4.46.53
uptime               : 00:00:00.9508691
appEnvironment       :
appEnvironmentSticky :
content              : 1.0.8
```

#### Recreate

Using update strategy `Recreate`:

```powershell
05/06/2022 07:49:41: 00:00:07.0655824
machineName          : webapp-fs-tester-demo-7f94d9db-pkvtn
started              : 6.5.2022 4.49.39
uptime               : 00:00:02.3469830
appEnvironment       :
appEnvironmentSticky :
content              : 1.0.8


05/06/2022 07:50:01: 00:00:19.7484896 -> Offline
05/06/2022 07:50:11: 00:00:09.1061795
machineName          : webapp-fs-tester-demo-599dbcfb5-tn76m
started              : 6.5.2022 4.50.10
uptime               : 00:00:01.8536378
appEnvironment       :
appEnvironmentSticky :
content              : 1.0.9
```

### Two nodes

#### Deployment -> RollingUpdate

Using update strategy `RollingUpdate`:

```
kubectl get pod -n demos

NAME                                    READY   STATUS              RESTARTS   AGE
webapp-fs-tester-demo-599dbcfb5-54cff   0/1     ContainerCreating   0          15m
webapp-fs-tester-demo-7f94d9db-2bs4j    1/1     Running             0          25m

Events:
  Type     Reason              Age                From                     Message
  ----     ------              ----               ----                     -------
  Normal   Scheduled           16m                default-scheduler        Successfully assigned demos/webapp-fs-tester-demo-599dbcfb5-54cff to aks-nodepool1-13507708-vmss000003
  Warning  FailedAttachVolume  16m                attachdetach-controller  Multi-Attach error for volume "pvc-ec14e20f-64f4-42ea-b29a-57f1bc3fa788" Volume is already used by pod(s) webapp-fs-tester-demo-7f94d9db-2bs4j
  Warning  FailedMount         14m                kubelet                  Unable to attach or mount volumes: unmounted volumes=[premiumdisk], unattached volumes=[kube-api-access-f9q7s premiumdisk]: timed out waiting for the condition
  Warning  FailedMount         29s (x6 over 11m)  kubelet                  Unable to attach or mount volumes: unmounted volumes=[premiumdisk], unattached volumes=[premiumdisk kube-api-access-f9q7s]: timed out waiting for the condition
```

#### Deployment -> Recreate

Using update strategy `Recreate`:

```powershell
05/06/2022 08:04:04: 00:00:01.0171024
machineName          : webapp-fs-tester-demo-599dbcfb5-tn76m
started              : 6.5.2022 4.50.10
uptime               : 00:13:54.5678609
appEnvironment       :
appEnvironmentSticky :
content              : 1.0.9


05/06/2022 08:04:36: 00:00:31.8650062 -> Offline
05/06/2022 08:05:26: 00:00:49.6406328
machineName          : webapp-fs-tester-demo-7f94d9db-ghxtq
started              : 6.5.2022 5.05.23
uptime               : 00:00:03.6706291
appEnvironment       :
appEnvironmentSticky :
content              : 1.0.8


05/06/2022 08:05:28: 00:00:01.0150013 -> Offline
05/06/2022 08:05:30: 00:00:01.0152121
machineName          : webapp-fs-tester-demo-7f94d9db-ghxtq
started              : 6.5.2022 5.05.23
uptime               : 00:00:06.8665084
appEnvironment       :
appEnvironmentSticky :
content              : 1.0.8
```

```bash
Events:
  Type     Reason                  Age    From                     Message
  ----     ------                  ----   ----                     -------
  Normal   Scheduled               6m33s  default-scheduler        Successfully assigned demos/webapp-fs-tester-demo-0 to aks-nodepool1-13507708-vmss000000
  Warning  FailedAttachVolume      6m33s  attachdetach-controller  Multi-Attach error for volume "pvc-ec14e20f-64f4-42ea-b29a-57f1bc3fa788" Volume is already exclusively attached to one node and can't be attached to another
  Warning  FailedMount             4m30s  kubelet                  Unable to attach or mount volumes: unmounted volumes=[premiumdisk], unattached volumes=[kube-api-access-dxbp9 premiumdisk]: timed out waiting for the condition
  Warning  FailedMount             2m16s  kubelet                  Unable to attach or mount volumes: unmounted volumes=[premiumdisk], unattached volumes=[premiumdisk kube-api-access-dxbp9]: timed out waiting for the condition
  Normal   SuccessfulAttachVolume  20s    attachdetach-controller  AttachVolume.Attach succeeded for volume "pvc-ec14e20f-64f4-42ea-b29a-57f1bc3fa788"
  Normal   Pulling                 18s    kubelet                  Pulling image "jannemattila/webapp-update:1.0.8"
  Normal   Pulled                  17s    kubelet                  Successfully pulled image "jannemattila/webapp-update:1.0.8" in 836.314823ms
  Normal   Created                 17s    kubelet                  Created container webapp-fs-tester-demo
  Normal   Started                 17s    kubelet                  Started container webapp-fs-tester-demo
```
