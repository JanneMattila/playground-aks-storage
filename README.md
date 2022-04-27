# Playground AKS Storage

Playground for AKS and storage options.
This repository contains examples how to use `static` or `dynamic` provisioning
using different combinations of Azure storage services.
This includes `Azure Files` and `Azure NetApp Files`
with different protocols like `NFSv4.1` or `SMB`.
You can then performance test your storage setup, to see
if you get the throughput you need.
Example performance testing numbers has been put to [notes](notes.md).

## Usage

1. Clone this repository to your own machine
2. Open Workspace
  - Use WSL in Windows
  - Requires Bash
3. Open [setup.sh](setup.sh) to walk through steps to deploy this demo environment
  - Execute different script steps one-by-one (hint: use [shift-enter](https://github.com/JanneMattila/some-questions-and-some-answers/blob/master/q%26a/vs_code.md#automation-tip-shift-enter))

## Discussion topics

- [Storage options](https://docs.microsoft.com/en-us/azure/aks/concepts-storage)
- SKUs
  - Standard_LRS: Standard locally redundant storage
  - Standard_ZRS: Standard zone-redundant storage
  - Premium_ZRS: Premium zone-redundant storage
- [Container Storage Interface (CSI)](https://docs.microsoft.com/en-us/azure/aks/csi-storage-drivers)
  - [azurefile-csi-driver parameters](https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/driver-parameters.md)
- Azure Disk
- Azure Files
  - Premium
  - [Protocols](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-planning#available-protocols): [SMB](https://docs.microsoft.com/en-us/azure/storage/files/files-smb-protocol) or [NFS](https://docs.microsoft.com/en-us/azure/storage/files/files-nfs-protocol)
  - [NFS v4.1](https://docs.microsoft.com/en-us/azure/aks/azure-files-csi#nfs-file-shares)
  - [Scalability and performance targets](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-scale-targets)
- Azure NetApp Files
  - [Service levels for Azure NetApp Files](https://docs.microsoft.com/en-us/azure/azure-netapp-files/azure-netapp-files-service-levels)
- Zone redundant
  - [Azure disk availability zone support](https://docs.microsoft.com/en-us/azure/aks/availability-zones#azure-disk-availability-zone-support)
  - [Redundancy options for managed disks](https://docs.microsoft.com/en-us/azure/virtual-machines/disks-redundancy)
  - [Use the Azure disk Container Storage Interface (CSI) drivers in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/azure-disk-csi)
- Static vs. Dynamic [provisioning](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#provisioning)
  - What if you need to re-create the cluster?
- [Compare access to Azure Files, Blob Storage, and Azure NetApp Files with NFS](https://docs.microsoft.com/en-us/azure/storage/common/nfs-comparison)
- Azure Blob storage NFS v3.0
- [Availability Zones](https://kubernetes-sigs.github.io/cloud-provider-azure/topics/availability-zones/)
