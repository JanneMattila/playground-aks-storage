#!/bin/bash

# Register SAN Storage provider
az provider register -n Microsoft.ElasticSan
az provider show -n Microsoft.ElasticSan -o table

# Add Azure Container Storage support to AKS
az aks nodepool update -g $resource_group_name --cluster-name $aks_name --name nodepool1 --labels acstor.azure.com/io-engine=acstor

az role assignment create --assignee $kubelet_identity_object_id --role "Contributor" --resource-group $aks_node_resource_group_name

az k8s-extension create \
  --cluster-type managedClusters \
  --cluster-name $aks_name \
  --resource-group $resource_group_name \
  --name acstor \
  --extension-type microsoft.azurecontainerstorage \
  --scope cluster \
  --release-train prod \
  --release-namespace acstor

# It might take 10-15 minutes
az k8s-extension list --cluster-name $aks_name --resource-group $resource_group_name --cluster-type managedClusters

# Create SAN Storage pool
kubectl apply -f static/acstor/san-storagepool.yaml

kubectl describe sp san-storagepool -n acstor

kubectl get storageclasses

kubectl describe storageclasses acstor-azuredisk-internal
