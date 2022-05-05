#!/bin/bash

# Install driver on AKS
# https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/install-driver-on-aks.md

# Install blob csi driver
# https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/install-blob-csi-driver.md
curl -skSL https://raw.githubusercontent.com/kubernetes-sigs/blob-csi-driver/master/deploy/install-driver.sh | bash -s master blobfuse-proxy --

# Example storage classes:
# https://raw.githubusercontent.com/kubernetes-sigs/blob-csi-driver/master/deploy/example/storageclass-blobfuse.yaml
# https://raw.githubusercontent.com/kubernetes-sigs/blob-csi-driver/master/deploy/example/storageclass-blob-nfs.yaml

kubectl get storageclasses

# Create blob ahead of time => static provisioning
storageid=$(az storage account create \
  --name $premiumStorageName \
  --resource-group $resourceGroupName \
  --location "$location" \
  --sku Standard_ZRS \
  --kind StorageV2 \
  --https-only true \
  --query id -o tsv)
echo $storageid

premiumStorageKey=$(az storage account keys list \
  --account-name $premiumStorageName \
  --resource-group $resourceGroupName \
  --query [0].value \
  -o tsv)
echo $premiumStorageKey

az storage container create --name $premiumStorageBlobContainerName --account-name $premiumStorageName

# Deploy storage secret
kubectl create secret generic azureblob-secret \
  --from-literal=azurestorageaccountname=$premiumStorageName \
  --from-literal=azurestorageaccountkey=$premiumStorageKey \
  -n demos --type Opaque --dry-run=client -o yaml > azureblob-secret.yaml
cat azureblob-secret.yaml
kubectl apply -f azureblob-secret.yaml

# Enable static provisioning
cat static/azureblob-csi-fuse/azureblob-sc.yaml | envsubst | kubectl apply -f -
cat static/azureblob-csi-fuse/persistent-volume.yaml | envsubst | kubectl apply -f -
cat static/azureblob-csi-fuse/persistent-volume-claim.yaml | envsubst | kubectl apply -f -

kubectl get pv -n demos
kubectl get pvc -n demos

kubectl describe pv blobfuse-pv -n demos
kubectl describe pvc blobfuse-pvc -n demos
