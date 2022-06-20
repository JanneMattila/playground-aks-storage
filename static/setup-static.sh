#!/bin/bash

# Create Premium ZRS file share ahead of time => static provisioning
# NFS related notes from Azure portal if "Secure transfer required" is enabled:
#   "Secure transfer required" is a setting that is enabled for this storage account. 
#   The NFS protocol does not support encryption and relies on network-level security. 
#   This setting must be disabled for NFS to work.
storage_id=$(az storage account create \
  --name $premium_storage_name \
  --resource-group $resource_group_name \
  --location $location \
  --sku Premium_ZRS \
  --kind FileStorage \
  --default-action Deny \
  --allow-blob-public-access false \
  --public-network-access Disabled \
  --https-only false \
  --query id -o tsv)
echo $storage_id

premium_storage_key=$(az storage account keys list \
  --account-name $premium_storage_name \
  --resource-group $resource_group_name \
  --query [0].value \
  -o tsv)
echo $premium_storage_key

az storage share-rm create --access-tier Premium --enabled-protocols SMB --quota 100 --name $premium_storage_share_name_smb --storage-account $premium_storage_name
az storage share-rm create --access-tier Premium --enabled-protocols NFS --quota 100 --name $premium_storage_share_name_nfs --storage-account $premium_storage_name

# Provisioned capacity: 100 GiB
# =>
# Performance
# Maximum IO/s     500
# Burst IO/s       4000
# Throughput rate  70.0 MiBytes / s

# Follow instructions from here:
# https://docs.microsoft.com/en-us/azure/storage/files/storage-files-networking-endpoints?tabs=azure-cli
# Disable private endpoint network policies
az network vnet subnet update \
  --ids $subnet_storage_id \
  --disable-private-endpoint-network-policies \
  --output none

# Create private endpoint to "StorageSubnet"
storage_pe_id=$(az network private-endpoint create \
    --name storage-pe \
    --resource-group $resource_group_name \
    --vnet-name $vnet_name --subnet $subnet_storage \
    --private-connection-resource-id $storage_id \
    --group-id file \
    --connection-name storage-connection \
    --query id -o tsv)
echo $storage_pe_id

# Create Private DNS Zone
file_private_dns_zone_id=$(az network private-dns zone create \
    --resource-group $resource_group_name \
    --name "privatelink.file.core.windows.net" \
    --query id -o tsv)
echo $file_private_dns_zone_id

# Link Private DNS Zone to VNET
az network private-dns link vnet create \
  --resource-group $resource_group_name \
  --zone-name "privatelink.file.core.windows.net" \
  --name file-dnszone-link \
  --virtual-network $vnet_name \
  --registration-enabled false

# Get private endpoint NIC
pe_nic_id=$(az network private-endpoint show \
  --ids $storage_pe_id \
  --query "networkInterfaces[0].id" -o tsv)
echo $pe_nic_id

# Get ip of private endpoint NIC
pe_ip=$(az network nic show \
  --ids $pe_nic_id \
  --query "ipConfigurations[0].privateIpAddress" -o tsv)
echo $pe_ip

# Map private endpoint ip to A record in Private DNS Zone
az network private-dns record-set a create \
  --resource-group $resource_group_name \
  --zone-name "privatelink.file.core.windows.net" \
  --name $premium_storage_name \
  --output none

az network private-dns record-set a add-record \
  --resource-group $resource_group_name \
  --zone-name "privatelink.file.core.windows.net" \
  --record-set-name $premium_storage_name \
  --ipv4-address $pe_ip \
  --output none

# Deploy storage secret
kubectl create secret generic azurefile-secret \
  --from-literal=azurestorageaccountname=$premium_storage_name \
  --from-literal=azurestorageaccountkey=$premium_storage_key \
  -n demos --type Opaque --dry-run=client -o yaml > azurefile-secret.yaml
cat azurefile-secret.yaml
kubectl apply -f azurefile-secret.yaml

# Enable static provisioning
kubectl apply -f static/azurefile-csi-nfs
kubectl apply -f static/azurefile-csi-premium

kubectl get pv -n demos
kubectl get pvc -n demos

kubectl describe pv nfs-pv -n demos
kubectl describe pvc nfs-pvc -n demos

kubectl describe pv smb-pv -n demos
kubectl describe pvc smb-pvc -n demos

###################################################################### 
#     _                          ____  _     _       ____ ____ ___
#    / \    _____   _ _ __ ___  |  _ \(_)___| | __  / ___/ ___|_ _|
#   / _ \  |_  / | | | '__/ _ \ | | | | / __| |/ / | |   \___ \| |
#  / ___ \  / /| |_| | | |  __/ | |_| | \__ \   <  | |___ ___) | |
# /_/   \_\/___|\__,_|_|  \___| |____/|_|___/_|\_\  \____|____/___|
# 
#  ____       _                 __     ______
# |  _ \ _ __(_)_   _____ _ __  \ \   / /___ \
# | | | | '__| \ \ / / _ \ '__|  \ \ / /  __) |
# | |_| | |  | |\ V /  __/ |      \ V /  / __/
# |____/|_|  |_| \_/ \___|_|       \_/  |_____|
# Entering into experimental area
###################################################################### 

# Relevant links
# https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/docs/design-v2.md
# https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/deploy/example/failover/README.md
# https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/docs/perf-profiles.md

# Install the Azure Disk CSI Driver V2
branch="main_v2" # vs. master
version="v2.0.0-beta.3" # vs. v2.0.0-alpha.1

# helm repo remove azuredisk-csi-driver
helm repo add azuredisk-csi-driver https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/$branch/charts
helm search repo -l azuredisk-csi-driver --devel

# helm uninstall azuredisk-csi-driver-v2 --namespace=kube-system
helm install azuredisk-csi-driver-v2 azuredisk-csi-driver/azuredisk-csi-driver \
  --namespace kube-system \
  --version $version \
  --values=https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/$branch/charts/$version/azuredisk-csi-driver/side-by-side-values.yaml

helm status azuredisk-csi-driver-v2 --namespace=kube-system
kubectl --namespace=kube-system get pods --selector="app.kubernetes.io/instance=azuredisk-csi-driver-v2"
# NAME                                                  READY   STATUS    RESTARTS   AGE
# csi-azuredisk-scheduler-extender-57599ff9c-78kr5      2/2     Running   0          50s
# csi-azuredisk-scheduler-extender-57599ff9c-qxwpf      2/2     Running   0          50s
# csi-azuredisk2-controller-7fbcc644fd-kfkhn            6/6     Running   0          50s
# csi-azuredisk2-controller-7fbcc644fd-qpfbg            6/6     Running   0          50s
# csi-azuredisk2-node-8glj9                             3/3     Running   0          50s
# csi-azuredisk2-node-mn5wq                             3/3     Running   0          50s
# csi-azuredisk2-node-s8fht                             3/3     Running   0          50s
# csi-azuredisk2-snapshot-controller-6f59cd479c-5xpd6   1/1     Running   0          50s

kubectl get storageclasses
# NAME                                  PROVISIONER           RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
# azuredisk-premium-ssd-lrs             disk2.csi.azure.com   Delete          WaitForFirstConsumer   true                   94s
# azuredisk-premium-ssd-lrs-replicas    disk2.csi.azure.com   Delete          WaitForFirstConsumer   true                   94s
# azuredisk-premium-ssd-zrs             disk2.csi.azure.com   Delete          Immediate              true                   94s
# azuredisk-premium-ssd-zrs-replicas    disk2.csi.azure.com   Delete          Immediate              true                   94s
# azuredisk-standard-hdd-lrs            disk2.csi.azure.com   Delete          WaitForFirstConsumer   true                   94s
# azuredisk-standard-ssd-lrs            disk2.csi.azure.com   Delete          WaitForFirstConsumer   true                   94s
# azuredisk-standard-ssd-lrs-replicas   disk2.csi.azure.com   Delete          WaitForFirstConsumer   true                   94s
# azuredisk-standard-ssd-zrs            disk2.csi.azure.com   Delete          Immediate              true                   94s
# azuredisk-standard-ssd-zrs-replicas   disk2.csi.azure.com   Delete          Immediate              true                   94s
# azurefile                             file.csi.azure.com    Delete          Immediate              true                   13m
# azurefile-csi                         file.csi.azure.com    Delete          Immediate              true                   13m
# azurefile-csi-premium                 file.csi.azure.com    Delete          Immediate              true                   13m
# azurefile-premium                     file.csi.azure.com    Delete          Immediate              true                   13m
# default (default)                     disk.csi.azure.com    Delete          WaitForFirstConsumer   true                   13m
# managed                               disk.csi.azure.com    Delete          WaitForFirstConsumer   true                   13m
# managed-csi                           disk.csi.azure.com    Delete          WaitForFirstConsumer   true                   13m
# managed-csi-premium                   disk.csi.azure.com    Delete          WaitForFirstConsumer   true                   13m
# managed-premium                       disk.csi.azure.com    Delete          WaitForFirstConsumer   true                   13m

# We're managing the kubelet identity, therefore we need to assign
# additional permissions to that identity, so that it can create storages
az role assignment create \
  --role "Contributor" \
  --assignee-object-id $kubelet_identity_object_id \
  --assignee-principal-type ServicePrincipal \
  --scope $aks_node_resource_group_id

kubectl describe storageclass azuredisk-premium-ssd-zrs-replicas

kubectl apply -f static/azuredisk-csi-v2

kubectl get pvc -n demos
# NAME                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS          AGE
# premiumdisk-v2-pvc   Bound    pvc-edbeefce-220e-49f0-b3f4-b8138d724e65   5Gi        RWO            azuredisk-csi-v2-sc   34s

kubectl describe pvc premiumdisk-v2-pvc -n demos
# This might give following error message in case you have not granted additional
# roles for kubelet identity:
#  Type     Reason                Age                From                                                                                        Message
#  ----     ------                ----               ----                                                                                        -------
#  Normal   Provisioning          31s (x2 over 32s)  disk2.csi.azure.com_aks-nodepool1-95262068-vmss000001_0400c4a9-7bf7-4015-9e94-b73fce9a7a65  External provisioner is provisioning volume for claim "demos/premiumdisk-v2-pvc"
#  Warning  ProvisioningFailed    31s                disk2.csi.azure.com_aks-nodepool1-95262068-vmss000001_0400c4a9-7bf7-4015-9e94-b73fce9a7a65  
#    failed to provision volume with StorageClass "azuredisk-csi-v2-sc": rpc error: code = FailedPrecondition desc = Retriable: false, 
#    RetryAfter: 0s, HTTPStatusCode: 403, RawError: {"error":{"code":"AuthorizationFailed","message":"The client '61e01c50-4c03-4603-9a11-1a1019e6fa1d' 
#    with object id '61e01c50-4c03-4603-9a11-1a1019e6fa1d' does not have authorization to perform action 'Microsoft.Compute/disks/write' over scope 
#    '/subscriptions/5286e93e-b901-4ac7-8d34-407a6e9a58a0/resourceGroups/mc_rg-myaksstorage_myaksstorage_westeurope/providers/Microsoft.Compute/disks/pvc-dcb2fd62-85cd-4311-8ca6-b11c6fdcf8d6'
#    or the scope is invalid. If access was recently granted, please refresh your credentials."}}
#