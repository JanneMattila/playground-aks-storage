#!/bin/bash

# All the variables for the deployment
subscriptionName="AzureDev"
aadAdminGroupContains="janne''s"

aksName="myaksstorage"
premiumStorageName="myaksstorage00010"
premiumStorageShareNameSMB="smb"
premiumStorageShareNameNFS="nfs"
workspaceName="mystorageworkspace"
vnetName="myaksstorage-vnet"
subnetAks="AksSubnet"
subnetStorage="StorageSubnet"
identityName="myaksstorage"
resourceGroupName="rg-myaksstorage"
location="westeurope"

# Login and set correct context
az login -o table
az account set --subscription $subscriptionName -o table

subscriptionID=$(az account show -o tsv --query id)
az group create -l $location -n $resourceGroupName -o table

# Prepare extensions and providers
az extension add --upgrade --yes --name aks-preview

# Enable feature
az feature register --namespace "Microsoft.ContainerService" --name "PodSubnetPreview"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/PodSubnetPreview')].{Name:name,State:properties.state}"
az provider register --namespace Microsoft.ContainerService

# Remove extension in case conflicting previews
az extension remove --name aks-preview

aadAdmingGroup=$(az ad group list --display-name $aadAdminGroupContains --query [].objectId -o tsv)
echo $aadAdmingGroup

workspaceid=$(az monitor log-analytics workspace create -g $resourceGroupName -n $workspaceName --query id -o tsv)
echo $workspaceid

vnetid=$(az network vnet create -g $resourceGroupName --name $vnetName \
  --address-prefix 10.0.0.0/8 \
  --query newVNet.id -o tsv)
echo $vnetid

subnetaksid=$(az network vnet subnet create -g $resourceGroupName --vnet-name $vnetName \
  --name $subnetAks --address-prefixes 10.2.0.0/24 \
  --query id -o tsv)
echo $subnetaksid

subnetstorageid=$(az network vnet subnet create -g $resourceGroupName --vnet-name $vnetName \
  --name $subnetStorage --address-prefixes 10.3.0.0/24 \
  --query id -o tsv)
echo $subnetstorageid

identityid=$(az identity create --name $identityName --resource-group $resourceGroupName --query id -o tsv)
echo $identityid

az aks get-versions -l $location -o table

# Note: for public cluster you need to authorize your ip to use api
myip=$(curl --no-progress-meter https://api.ipify.org)
echo $myip

# Note about private clusters:
# https://docs.microsoft.com/en-us/azure/aks/private-clusters

# For private cluster add these:
#  --enable-private-cluster
#  --private-dns-zone None

az aks create -g $resourceGroupName -n $aksName \
 --zones 1 2 3 --max-pods 50 --network-plugin azure \
 --node-count 3 --enable-cluster-autoscaler --min-count 3 --max-count 4 \
 --node-osdisk-type Ephemeral \
 --node-vm-size Standard_D8ds_v4 \
 --kubernetes-version 1.21.2 \
 --enable-addons monitoring,azure-policy,azure-keyvault-secrets-provider \
 --enable-aad \
 --enable-managed-identity \
 --aad-admin-group-object-ids $aadAdmingGroup \
 --workspace-resource-id $workspaceid \
 --load-balancer-sku standard \
 --vnet-subnet-id $subnetaksid \
 --assign-identity $identityid \
 --api-server-authorized-ip-ranges $myip \
 -o table 

###################################################################
# Enable current ip
az aks update -g $resourceGroupName -n $aksName --api-server-authorized-ip-ranges $myip

# Clear all authorized ip ranges
az aks update -g $resourceGroupName -n $aksName --api-server-authorized-ip-ranges ""
###################################################################

sudo az aks install-cli

az aks get-credentials -n $aksName -g $resourceGroupName --overwrite-existing

kubectl get nodes

kubectl get nodes -o custom-columns=NAME:'{.metadata.name}',REGION:'{.metadata.labels.topology\.kubernetes\.io/region}',ZONE:'{metadata.labels.topology\.kubernetes\.io/zone}'
# NAME                                REGION       ZONE
# aks-nodepool1-30714164-vmss000000   westeurope   westeurope-1
# aks-nodepool1-30714164-vmss000001   westeurope   westeurope-2
# aks-nodepool1-30714164-vmss000002   westeurope   westeurope-3

kubectl get storageclasses
# NAME                    PROVISIONER                RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
# azurefile               kubernetes.io/azure-file   Delete          Immediate              true                   25m
# azurefile-csi           file.csi.azure.com         Delete          Immediate              true                   25m
# azurefile-csi-premium   file.csi.azure.com         Delete          Immediate              true                   25m
# azurefile-premium       kubernetes.io/azure-file   Delete          Immediate              true                   25m
# default (default)       disk.csi.azure.com         Delete          WaitForFirstConsumer   true                   25m
# managed                 kubernetes.io/azure-disk   Delete          WaitForFirstConsumer   true                   25m
# managed-csi             disk.csi.azure.com         Delete          WaitForFirstConsumer   true                   25m
# managed-csi-premium     disk.csi.azure.com         Delete          WaitForFirstConsumer   true                   25m
# managed-premium         kubernetes.io/azure-disk   Delete          WaitForFirstConsumer   true                   25m

kubectl describe storageclass azurefile-csi
kubectl describe storageclass azurefile-csi-premium

# Enable Azure File with NFS to enable dynamic provisioning
kubectl apply -f azurefile-csi-nfs/azurefile-csi-nfs.yaml

# =>
# NAME                    PROVISIONER                RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
# ...
# azurefile-csi-nfs       file.csi.azure.com         Delete          Immediate              true                   3s

# Create Premium ZRS file share ahead of time => static provisioning
# NFS related notes from Azure portal if "Secure transfer required" is enabled:
#   "Secure transfer required" is a setting that is enabled for this storage account. 
#   The NFS protocol does not support encryption and relies on network-level security. 
#   This setting must be disabled for NFS to work.
storageid=$(az storage account create \
  --name $premiumStorageName \
  --resource-group $resourceGroupName \
  --location $location \
  --sku Premium_ZRS \
  --kind FileStorage \
  --allow-blob-public-access false \
  --public-network-access Disabled \
  --https-only false \
  --query id -o tsv)
echo $storageid

premiumStorageKey=$(az storage account keys list \
  --account-name $premiumStorageName \
  --resource-group $resourceGroupName \
  --query [0].value \
  -o tsv)
echo $premiumStorageKey

az storage share-rm create --access-tier Premium --enabled-protocols SMB --quota 100 --name $premiumStorageShareNameSMB --storage-account $premiumStorageName
az storage share-rm create --access-tier Premium --enabled-protocols NFS --quota 100 --name $premiumStorageShareNameNFS --storage-account $premiumStorageName

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
  --ids $subnetstorageid \
  --disable-private-endpoint-network-policies \
  --output none

# Create private endpoint to "StorageSubnet"
storagepeid=$(az network private-endpoint create \
    --name storage-pe \
    --resource-group $resourceGroupName \
    --vnet-name $vnetName --subnet $subnetStorage \
    --private-connection-resource-id $storageid \
    --group-id file \
    --connection-name storage-connection \
    --query id -o tsv)
echo $storagepeid

# Create Private DNS Zone
fileprivatednszoneid=$(az network private-dns zone create \
    --resource-group $resourceGroupName \
    --name "privatelink.file.core.windows.net" \
    --query id -o tsv)
echo $fileprivatednszoneid

# Link Private DNS Zone to VNET
az network private-dns link vnet create \
  --resource-group $resourceGroupName \
  --zone-name "privatelink.file.core.windows.net" \
  --name file-dnszone-link \
  --virtual-network $vnetName \
  --registration-enabled false

# Get private endpoint NIC
penicid=$(az network private-endpoint show \
  --ids $storagepeid \
  --query "networkInterfaces[0].id" -o tsv)
echo $penicid

# Get ip of private endpoint NIC
peip=$(az network nic show \
  --ids $penicid \
  --query "ipConfigurations[0].privateIpAddress" -o tsv)
echo $peip

# Map private endpoint ip to A record in Private DNS Zone
az network private-dns record-set a create \
  --resource-group $resourceGroupName \
  --zone-name "privatelink.file.core.windows.net" \
  --name $premiumStorageName \
  --output none

az network private-dns record-set a add-record \
  --resource-group $resourceGroupName \
  --zone-name "privatelink.file.core.windows.net" \
  --record-set-name $premiumStorageName \
  --ipv4-address $peip \
  --output none

# Start kubernetes app deployments

kubectl apply -f namespace.yaml

kubectl create secret generic azurefile-secret \
  --from-literal=azurestorageaccountname=$premiumStorageName \
  --from-literal=azurestorageaccountkey=$premiumStorageKey \
  -n demos --type Opaque --dry-run=client -o yaml > azurefile-secret.yaml
cat azurefile-secret.yaml
kubectl apply -f azurefile-secret.yaml

# For static provisioning examples use these
kubectl apply -f static/azurefile-csi-nfs
kubectl apply -f static/azurefile-csi-premium

# For dynamic provisioning examples use these
kubectl apply -f dynamic/azurefile-csi-nfs
kubectl apply -f dynamic/azurefile-csi-premium

kubectl get pv -n demos
kubectl get pvc -n demos

kubectl describe pv nfs-pv -n demos
kubectl describe pvc nfs-pvc -n demos

kubectl describe pv smb-pv -n demos
kubectl describe pvc smb-pvc -n demos

kubectl apply -f demos

kubectl get deployment -n demos
kubectl describe deployment -n demos

kubectl get pod -n demos
pod1=$(kubectl get pod -n demos -o name | head -n 1)
echo $pod1

kubectl describe $pod1 -n demos

kubectl get service -n demos

ingressip=$(kubectl get service -n demos -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")
echo $ingressip

curl $ingressip/swagger/index.html
# -> OK!

cat <<EOF > payload.json
{
  "path": "/mnt/nfs",
  "filter": "*.*",
  "recursive": true
}
EOF

# Quick tests
# - NFS
curl --no-progress-meter -X POST --data '{"path": "/mnt/nfs","filter": "*.*","recursive": true}' -H "Content-Type: application/json" "http://$ingressip/api/files" | jq .milliseconds
# - SMB
curl --no-progress-meter -X POST --data '{"path": "/mnt/smb","filter": "*.*","recursive": true}' -H "Content-Type: application/json" "http://$ingressip/api/files" | jq .milliseconds

# Test same in loop
# - NFS
for i in {0..50}
do 
  curl --no-progress-meter -X POST --data '{"path": "/mnt/nfs","filter": "*.*","recursive": true}' -H "Content-Type: application/json" "http://$ingressip/api/files" | jq .milliseconds
done
# - SMB
for i in {0..50}
do 
  curl --no-progress-meter -X POST --data '{"path": "/mnt/smb","filter": "*.*","recursive": true}' -H "Content-Type: application/json" "http://$ingressip/api/files" | jq .milliseconds
done

# Connect to first pod
pod1=$(kubectl get pod -n demos -o name | head -n 1)
echo $pod1
kubectl exec --stdin --tty $pod1 -n demos -- /bin/sh

##############
# fio examples
##############
mount
fdisk -l

# If not installed, then install
apk add --no-cache fio

fio

cd /mnt/nfs
cd /mnt/smb
mkdir perf-test

# Write test with 4 x 4MBs for 20 seconds
fio --directory=perf-test --direct=1 --rw=randwrite --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1

# Read test with 4 x 4MBs for 20 seconds
fio --directory=perf-test --direct=1 --rw=randread --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1 --readonly

# Find test files
ls perf-test/*.0

# Remove test files
rm perf-test/*.0

# Exit container shell
exit

# Wipe out the resources
az group delete --name $resourceGroupName -y
