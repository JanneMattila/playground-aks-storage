#!/bin/bash

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
kubectl apply -f dynamic/azurefile-csi-nfs/azurefile-csi-nfs.yaml

# =>
# NAME                    PROVISIONER                RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
# ...
# azurefile-csi-nfs       file.csi.azure.com         Delete          Immediate              true                   3s

# Enable dynamic provisioning
#
# Important note:
# - Modify driver parameters accordingly to match your deployment scenario:
# https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/driver-parameters.md
# - Pay attention to e.g, "networkEndpointType", "allowBlobPublicAccess" and others
#   which impact network configuration and security.
kubectl apply -f dynamic/azurefile-csi-nfs
kubectl apply -f dynamic/azurefile-csi-premium

kubectl get pv -n demos
kubectl get pvc -n demos

kubectl describe pvc nfs-pvc -n demos
kubectl describe pvc smb-pvc -n demos

#######################
# Azure
#  ____  _     _
# |  _ \(_)___| | __
# | | | | / __| |/ /
# | |_| | \__ \   <
# |____/|_|___/_|\_\
# examples
#######################

# Enable Premium Disk with dynamic provisioning
# - Run this to create Locally redundant storage (LRS)
kubectl apply -f dynamic/azuredisk
# - Run this to create Zone-redundant storage (ZRS)
kubectl apply -f dynamic/azuredisk-zrs

kubectl describe pvc premiumdisk-pvc -n demos

# Enable Ultra Disk with dynamic provisioning
kubectl apply -f dynamic/ultradisk

kubectl describe pvc ultradisk-pvc -n demos
