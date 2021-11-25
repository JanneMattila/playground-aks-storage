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
 -o table 

###################################################################
# Note: for public cluster you need to authorize your ip to use api
myip=$(curl --no-progress-meter https://api.ipify.org)
echo $myip

# Enable current ip
az aks update -g $resourceGroupName -n $aksName \
  --api-server-authorized-ip-ranges $myip

# Clear all authorized ip ranges
az aks update -g $resourceGroupName -n $aksName \
  --api-server-authorized-ip-ranges ""
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

# Create Premium ZRS file share
az storage account create \
  --name $premiumStorageName \
  --resource-group $resourceGroupName \
  --location $location \
  --sku Premium_ZRS \
  --kind FileStorage \
  --https-only

premiumStorageKey=$(az storage account keys list \
  --account-name $premiumStorageName \
  --resource-group $resourceGroupName \
  --query [0].value \
  -o TSV)
echo $premiumStorageKey

az storage share-rm create --access-tier Premium --enabled-protocols SMB --quota 100 --name $premiumStorageShareNameSMB --storage-account $premiumStorageName
az storage share-rm create --access-tier Premium --enabled-protocols NFS --quota 100 --name $premiumStorageShareNameNFS --storage-account $premiumStorageName

# Provisioned capacity: 100 GiB
# =>
# Performance
# Maximum IO/s     500
# Burst IO/s       4000
# Throughput rate  70.0 MiBytes / s

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

curl --no-progress-meter -X POST --data '{"path": "/mnt/nfs","filter": "*.*","recursive": true}' -H "Content-Type: application/json" "http://$ingressip/api/files" | jq .milliseconds
curl --no-progress-meter -X POST --data '{"path": "/mnt/smb","filter": "*.*","recursive": true}' -H "Content-Type: application/json" "http://$ingressip/api/files" | jq .milliseconds

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

exit

# Wipe out the resources
az group delete --name $resourceGroupName -y
