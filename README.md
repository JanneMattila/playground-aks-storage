# Playground AKS Storage

Playground for AKS and storage options

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
- Static vs. Dynamic [provisioning](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#provisioning)
  - What if you need to re-create the cluster?
- [Compare access to Azure Files, Blob Storage, and Azure NetApp Files with NFS](https://docs.microsoft.com/en-us/azure/storage/common/nfs-comparison)
- Azure Blob storage NFS v3.0
