# Enable auto export
set -a

# All the variables for the deployment
subscription_name="AzureDev"
azuread_admin_group_contains="janne''s"

aks_name="myaksstorage"
premium_storage_name="myaksstorage00010"
premium_storage_blob_container_name="blob"
premium_storage_share_name_smb="smb"
premium_storage_share_name_nfs="nfs"
workspace_name="log-mystorageworkspace"
vnet_name="vnet-myaksstorage"
subnet_aks_name="snet-aks"
subnet_storage_name="snet-storage"
subnet_netapp_name="snet-netapp"
cluster_identity_name="id-myaksstorage-cluster"
kubelet_identity_name="id-myaksstorage-kubelet"
resource_group_name="rg-myaksstorage"
location="westeurope"

# Login and set correct context
az login -o table
az account set --subscription $subscription_name -o table

# Prepare extensions and providers
az extension add --upgrade --yes --name aks-preview

# Enable feature
az feature register --namespace "Microsoft.ContainerService" --name "PodSubnetPreview"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/PodSubnetPreview')].{Name:name,State:properties.state}"
az provider register --namespace Microsoft.ContainerService

# Remove extension in case conflicting previews
# az extension remove --name aks-preview

az group create -l $location -n $resource_group_name -o table

azuread_admin_group_id=$(az ad group list --display-name $azuread_admin_group_contains --query [].id -o tsv)
echo $azuread_admin_group_id

workspace_id=$(az monitor log-analytics workspace create -g $resource_group_name -n $workspace_name --query id -o tsv)
echo $workspace_id

vnet_id=$(az network vnet create -g $resource_group_name --name $vnet_name \
  --address-prefix 10.0.0.0/8 \
  --query newVNet.id -o tsv)
echo $vnet_id

subnet_aks_id=$(az network vnet subnet create -g $resource_group_name --vnet-name $vnet_name \
  --name $subnet_aks_name --address-prefixes 10.2.0.0/24 \
  --query id -o tsv)
echo $subnet_aks_id

subnet_storage_id=$(az network vnet subnet create -g $resource_group_name --vnet-name $vnet_name \
  --name $subnet_storage_name --address-prefixes 10.3.0.0/24 \
  --query id -o tsv)
echo $subnet_storage_id

# Delegate a subnet to Azure NetApp Files
# https://docs.microsoft.com/en-us/azure/azure-netapp-files/azure-netapp-files-delegate-subnet
subnet_netapp_id=$(az network vnet subnet create -g $resource_group_name --vnet-name $vnet_name \
  --name $subnet_netapp_name --address-prefixes 10.4.0.0/28 \
  --delegations "Microsoft.NetApp/volumes" \
  --query id -o tsv)
echo $subnet_netapp_id

cluster_identity_json=$(az identity create --name $cluster_identity_name --resource-group $resource_group_name -o json)
kubelet_identity_json=$(az identity create --name $kubelet_identity_name --resource-group $resource_group_name -o json)
cluster_identity_id=$(echo $cluster_identity_json | jq -r .id)
kubelet_identity_id=$(echo $kubelet_identity_json | jq -r .id)
kubelet_identity_object_id=$(echo $kubelet_identity_json | jq -r .principalId)
echo $cluster_identity_id
echo $kubelet_identity_id
echo $kubelet_identity_object_id

az aks get-versions -l $location -o table

# Note: for public cluster you need to authorize your ip to use api
my_ip=$(curl --no-progress-meter https://api.ipify.org)
echo $my_ip

# Enable Ultra Disk:
# --enable-ultra-ssd

aks_json=$(az aks create -g $resource_group_name -n $aks_name \
 --zones 1 2 3 --max-pods 50 --network-plugin azure \
 --node-count 3 --enable-cluster-autoscaler --min-count 3 --max-count 4 \
 --node-osdisk-type Ephemeral \
 --node-vm-size Standard_D8ds_v4 \
 --kubernetes-version 1.23.5 \
 --enable-addons monitoring,azure-policy,azure-keyvault-secrets-provider \
 --enable-aad \
 --enable-azure-rbac \
 --disable-local-accounts \
 --aad-admin-group-object-ids $azuread_admin_group_id \
 --workspace-resource-id $workspace_id \
 --load-balancer-sku standard \
 --vnet-subnet-id $subnet_aks_id \
 --assign-identity $cluster_identity_id \
 --assign-kubelet-identity $kubelet_identity_id \
 --api-server-authorized-ip-ranges $my_ip \
 --enable-ultra-ssd \
 -o json)

aks_node_resource_group_name=$(echo $aks_json | jq -r .nodeResourceGroup)
aks_node_resource_group_id=$(az group show --name $aks_node_resource_group_name --query id -o tsv)
echo $aks_node_resource_group_id

###################################################################
# Enable current ip
az aks update -g $resource_group_name -n $aks_name --api-server-authorized-ip-ranges $my_ip

# Clear all authorized ip ranges
az aks update -g $resource_group_name -n $aks_name --api-server-authorized-ip-ranges ""
###################################################################

sudo az aks install-cli
az aks get-credentials -n $aks_name -g $resource_group_name --overwrite-existing
kubelogin convert-kubeconfig -l azurecli

kubectl get nodes
kubectl get nodes -o wide
kubectl get nodes -o custom-columns=NAME:'{.metadata.name}',REGION:'{.metadata.labels.topology\.kubernetes\.io/region}',ZONE:'{metadata.labels.topology\.kubernetes\.io/zone}'
# NAME                                REGION       ZONE
# aks-nodepool1-30714164-vmss000000   westeurope   westeurope-1
# aks-nodepool1-30714164-vmss000001   westeurope   westeurope-2
# aks-nodepool1-30714164-vmss000002   westeurope   westeurope-3

# List installed Container Storage Interfaces (CSI)
# More information here:
# https://docs.microsoft.com/en-us/azure/aks/csi-storage-drivers
# https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/driver-parameters.md
kubectl get storageclasses

kubectl describe storageclass azurefile-csi
kubectl describe storageclass azurefile-csi-premium
kubectl describe storageclass azurefile-premium
kubectl describe storageclass managed-premium
kubectl describe storageclass managed-csi-premium

# In simple diff view
diff <(kubectl describe storageclass azurefile-csi-premium) <(kubectl describe storageclass azurefile-premium)
diff <(kubectl describe storageclass azurefile-csi) <(kubectl describe storageclass azurefile-premium)
diff <(kubectl describe storageclass managed-premium) <(kubectl describe storageclass managed-csi-premium)

# Create namespace
kubectl apply -f namespace.yaml

# Continue using "static provisioning" example
# => static/setup-static.sh

# Continue using "static provisioning blob" example
# => static/setup-static-blob.sh

# Continue using "dynamic provisioning" example
# => dynamic/setup-dynamic.sh

kubectl apply -f demos/deployment.yaml
# kubectl apply -f demos/statefulset.yaml
kubectl apply -f demos/service.yaml

kubectl get deployment -n demos
kubectl describe deployment -n demos

kubectl get pod -n demos -o wide
kubectl describe pod -n demos
kubectl get pod -n demos -o custom-columns=NAME:'{.metadata.name}',NODE:'{.spec.nodeName}'

kubectl get pod -n demos
pod1=$(kubectl get pod -n demos -o name | head -n 1)
echo $pod1

kubectl describe $pod1 -n demos

kubectl get service -n demos

ingress_ip=$(kubectl get service -n demos -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")
echo $ingress_ip

curl $ingress_ip/swagger/index.html
# -> OK!

cat <<EOF > payload.json
{
  "path": "/mnt/nfs",
  "filter": "*.*",
  "recursive": true
}
EOF

# Quick tests
# - Azure Files NFSv4.1
curl --no-progress-meter -X POST --data '{"path": "/mnt/nfs","filter": "*.*","recursive": true}' -H "Content-Type: application/json" "http://$ingress_ip/api/files" | jq .milliseconds
# - Azure Files SMB
curl --no-progress-meter -X POST --data '{"path": "/mnt/smb","filter": "*.*","recursive": true}' -H "Content-Type: application/json" "http://$ingress_ip/api/files" | jq .milliseconds
# - Azure NetApp Files NFSv4.1
curl --no-progress-meter -X POST --data '{"path": "/mnt/netapp-nfs","filter": "*.*","recursive": true}' -H "Content-Type: application/json" "http://$ingress_ip/api/files" | jq .milliseconds

# Test same in loop
# - Azure Files NFSv4.1
for i in {0..50}
do 
  curl --no-progress-meter -X POST --data '{"path": "/mnt/nfs","filter": "*.*","recursive": true}' -H "Content-Type: application/json" "http://$ingress_ip/api/files" | jq .milliseconds
done
# Examples: 1.8357, 2.918, 1.9534, 2.9706, 1.7649, 1.8872

# - Azure Files SMB
for i in {0..50}
do 
  curl --no-progress-meter -X POST --data '{"path": "/mnt/smb","filter": "*.*","recursive": true}' -H "Content-Type: application/json" "http://$ingress_ip/api/files" | jq .milliseconds
done
# Examples: 15.7838, 10.2626, 14.653, 11.2682, 9.8133, 15.9403, 11.6134

# - Azure NetApp Files NFSv4.1
for i in {0..50}
do 
  curl --no-progress-meter -X POST --data '{"path": "/mnt/netapp-nfs","filter": "*.*","recursive": true}' -H "Content-Type: application/json" "http://$ingress_ip/api/files" | jq .milliseconds
done
# Examples: 0.4258, 0.3901,0.407, 0.5709, 0.3992, 0.3968

# Use upload and download APIs to test client to server latency and transfer performance
# You can also use calculators e.g., https://www.calculator.net/bandwidth-calculator.html#download-time
truncate -s 10m demo1.bin
ls -lhF *.bin
time curl -T demo1.bin -X POST "http://$ingress_ip/api/upload"
time curl --no-progress-meter -X POST --data '{"size": 10485760}' -H "Content-Type: application/json" "http://$ingress_ip/api/download" -o demo2.bin
rm *.bin

# Connect to first pod
pod1=$(kubectl get pod -n demos -o name | head -n 1)
echo $pod1
kubectl exec --stdin --tty $pod1 -n demos -- /bin/sh

##############
# fio examples
##############
mount
fdisk -l
df -h
cat /proc/partitions

# If not installed, then install
apk add --no-cache fio

fio

cd /mnt
ls
cd /mnt/empty
cd /mnt/hostpath
cd /mnt/nfs
cd /mnt/smb
cd /mnt/premiumdisk
cd /mnt/premiumdisk-v2
cd /mnt/ultradisk
cd /mnt/netapp-nfs
cd /home
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

################################
# To test
#  _____
# | ____|_ __ _ __ ___  _ __
# |  _| | '__| '__/ _ \| '__|
# | |___| |  | | | (_) | |
# |_____|_|  |_|  \___/|_|   s
# scenarios
################################

# Delete pod
# ----------
kubectl delete $pod1 -n demos

# Delete VM in VMSS
# -----------------
# Note: If you use Azure Disk with LRS from Zone-1, then
# killing node from matching zone will bring app down until
# AKS introduces new node to that zone.
# If your Azure Disk is ZRS, then pod will be scheduled to
# another zone and it will use storage from that zone.
vmss=$(az vmss list -g $aks_node_resource_group_name --query [0].name -o tsv)
az vmss list-instances -n $vmss -g $aks_node_resource_group_name -o table
vmss_vm1=$(az vmss list-instances -n $vmss -g $aks_node_resource_group_name --query [0].instanceId -o tsv)
echo $vmss_vm1
az vmss delete-instances --instance-ids $vmss_vm1 -n $vmss -g $aks_node_resource_group_name

# Note about ZRS: Migration of workload from one zone to another zone 
# might take some time and you might see these kind of messages before
# migration is successful:
kubectl describe pod -n demos
# 
# Events:
#  Type     Reason                  Age                   From                     Message
#  ----     ------                  ----                  ----                     -------
#  Normal   Scheduled               8m19s                 default-scheduler        Successfully assigned demos/webapp-fs-tester-demo-6844679846-nz57x to aks-nodepool1-29389741-vmss000001
#  Warning  FailedAttachVolume      8m19s                 attachdetach-controller  Multi-Attach error for volume "pvc-20aac590-010b-44f3-9173-7c5f0da7f8f2" Volume is already exclusively attached to one node and can't be attached to another
#  Warning  FailedMount             4m3s (x2 over 6m16s)  kubelet                  Unable to attach or mount volumes: unmounted volumes=[premiumdisk], unattached volumes=[premiumdisk kube-api-access-njm58]: timed out waiting for the condition
#  Normal   SuccessfulAttachVolume  2m6s                  attachdetach-controller  AttachVolume.Attach succeeded for volume "pvc-20aac590-010b-44f3-9173-7c5f0da7f8f2"
#  Warning  FailedMount             105s                  kubelet                  Unable to attach or mount volumes: unmounted volumes=[premiumdisk], unattached volumes=[kube-api-access-njm58 premiumdisk]: timed out waiting for the condition
#  Normal   Pulling                 3s                    kubelet                  Pulling image "jannemattila/webapp-fs-tester:1.1.7"
#
# More information here:
# https://github.com/kubernetes-sigs/azuredisk-csi-driver/tree/master/docs/known-issues/node-shutdown-recovery

#
# For comparison, here is matching output when using "azuredisk-csi-driver-v2" with version "v2.0.0-beta.3":
#
# Events:
#   Type     Reason                  Age    From                     Message
#   ----     ------                  ----   ----                     -------
#   Normal   Scheduled               3m21s  default-scheduler        Successfully assigned demos/webapp-fs-tester-demo-574867997f-txbk8 to aks-nodepool1-17745966-vmss000002
#   Warning  FailedAttachVolume      3m21s  attachdetach-controller  Multi-Attach error for volume "pvc-13868150-49ab-4c67-91b8-e583fd4c1cbf" Volume is already exclusively attached to one node and can't be attached to another
#   Warning  FailedMount             78s    kubelet                  Unable to attach or mount volumes: unmounted volumes=[premiumdisk-v2], unattached volumes=[premiumdisk-v2 kube-api-access-9mq9r]: timed out waiting for the condition
#   Normal   SuccessfulAttachVolume  9s     attachdetach-controller  AttachVolume.Attach succeeded for volume "pvc-13868150-49ab-4c67-91b8-e583fd4c1cbf"
#   Normal   Pulling                 6s     kubelet                  Pulling image "jannemattila/webapp-update:1.0.9"
#

# Wipe out the resources
az group delete --name $resource_group_name -y
