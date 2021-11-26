#!/bin/bash

netappName="myaksnetapp"
poolName="pool1"
servicelevel="Premium"
volumeName="volume1"
uniqueFilePath="netappnfs"

# Enable NetApp Provider
az provider register --namespace Microsoft.NetApp --wait

# Create Azure NetApp Files account
az netappfiles account create \
  --resource-group $resourceGroupName \
  --location $location \
  --account-name $netappName

# Create Premium pool with 4TB and Premium service level
az netappfiles pool create \
  --resource-group $resourceGroupName \
  --location $location \
  --account-name $netappName \
  --pool-name $poolName \
  --size 4 \
  --service-level $servicelevel

# Create Premium volume for 1TB
# https://docs.microsoft.com/en-us/azure/azure-netapp-files/azure-netapp-files-service-levels
# => The Premium storage tier provides up to 64 MiB/s of throughput per 1 TiB of capacity provisioned.
netappip=$(az netappfiles volume create \
  --resource-group $resourceGroupName \
  --location $location \
  --account-name $netappName \
  --pool-name $poolName \
  --name $volumeName \
  --service-level $servicelevel \
  --vnet $vnetid \
  --subnet $subnetnetappid \
  --usage-threshold 1000 \
  --file-path $uniqueFilePath \
  --allowed-clients 10.0.0.0/8 \
  --protocol-types "NFSv4.1" \
  --rule-index 1 \
  --unix-read-write true \
  --query "mountTargets[0].ipAddress" -o tsv)
echo $netappip

cat <<EOF > static/netapp/persistent-volume-netapp.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: netapp-nfs-pv
  namespace: demos
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  mountOptions:
    - vers=4.1
    - noatime
    - rw
    - hard
    - rsize=1048576
    - wsize=1048576
    - sec=sys
    - tcp
  nfs:
    server: $netappip
    path: /$uniqueFilePath
EOF
cat static/netapp/persistent-volume-netapp.yaml
kubectl apply -f static/netapp

kubectl get pv -n demos
kubectl get pvc -n demos

kubectl describe pv netapp-nfs-pv -n demos
kubectl describe pvc netapp-nfs-pvc -n demos

# Delete Azure NetApp Files resources
az netappfiles volume delete \
  --resource-group $resourceGroupName \
  --account-name $netappName \
  --pool-name $poolName \
  --name $volumeName
az netappfiles pool delete \
  --resource-group $resourceGroupName \
  --account-name $netappName \
  --pool-name $poolName
az netappfiles account delete \
  --resource-group $resourceGroupName \
  --account-name $netappName
