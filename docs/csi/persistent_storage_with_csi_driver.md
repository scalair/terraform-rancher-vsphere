# Persistent storage with CSI driver

## Introduction

Stateful workloads in Kubernetes need to be able to access persistent volumes across the cluster. Storage Classes represent different storage types in Kubernetes.

Most commonly used cloud providers have storage provisioners, which offer different capabilities based on the underlying cloud.

On this page, we will look at setting up your Rancher Kubernetes Engine (RKE) Kubernetes cluster running on VMware vSphere ready for stateful workloads. The CPI/CSI manifests are upstream VMware vSphere manifests, which have a few minor tweaks to factor in how RKE applies custom taints and run the various components making Kubernetes. VMware vSphere provides the persistent volumes for this workload.

Kubernetes allows native integration with a wide variety of cloud providers. There are 2 types of cloud providers :

- in-tree cloud providers : providers developed and released by Kubernetes
- out-of-tree cloud providers : providers developed, built and releases independent of Kubernetes core

Originally, kube-controller-manager handled the implementation of cloud-provider control loops. This meant that changes to cloud providers were coupled with Kubernetes.

Kubernetes v1.6 introduced a component called cloud-controller-manager to offload the cloud management control loops from kube-controller-manager. The idea was to decouple cloud provider logic from core Kubernetes and allow cloud providers to write their own out-of-tree cloud providers, which implemented the Cloud Provider Interface (CPI).

Similarly, Storage Classes perform storage management. Traditionally, in-tree volume plugins managed volume provisioning. Kubernetes introduced the concept of Container Storage Interface (CSI) in v1.9 as Alpha. This reached GA in v1.13. Using CSI, third-party vendors can write volume plugins that can be deployed and managed outside the Kubernetes lifecycle.

VMware introduced its out-of-tree CPI/CSI in May 2019, which allows users to decouple cloud management capabilities from underlying Kubernetes.

## Prerequisites

Some prerequisites are mandatories :

- VMware environment with vCenter 6.7U3+, ESXi v6.7.0+
- Kubernetes cluster provisioned using RKE. Kubernetes version 1.14+
- Virtual machines with hardware version 15 or later.
- vmtools on each virtual machine.
- `cluster_template_kubelet_extra_binds` must be properly configured. See the usage in `README.md` file.

## Install CSI/CPI on Kubernetes cluster

Different ways to install it regarding the Kubernetes nodes's OSes.

### With RancherOS kubernetes nodes

Before installing it, you must configure some files under `docs/csi` directory, with your vSphere information :

- cpi-secret.conf
- cpi-vsphere.conf
- csi-vsphere.conf
- storage-class.yaml

Then, execute the followings :

```bash
$ kubectl create configmap cloud-config --from-file=manifests/cpi-vsphere.conf --namespace=kube-system
$ kubectl create -f manifests/cpi-secret.conf
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/cloud-controller-manager-roles.yaml
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/cloud-controller-manager-role-bindings.yaml
$ kubectl apply -f manifests/cloud-provider.yaml
$ kubectl create secret generic vsphere-config-secret --from-file=manifests/csi-vsphere.conf --namespace=kube-system
$ kubectl apply -f manifests/csi-driver-rbac.yaml
$ kubectl create -f manifests/csi-controller.yaml
$ kubectl apply -f manifests/csi-driver.yaml
$ kubectl apply -f manifests/storage-class.yaml
```

After performing these steps, you should be able to provision persistent volumes on VMware vSphere using the newly created Storage Class.

Now, persistent volume requests will not be managed by the out-of-tree CPI/CSI provider.

### With Ubuntu kubernetes nodes

Before installing it, you must configure some files under `docs/csi` directory, with your vSphere information :

- cpi-secret.conf
- cpi-vsphere.conf
- csi-vsphere.conf
- storage-class.yaml

Then, execute the followings :

```bash
$ cd docs/csi
$ kubectl create configmap cloud-config --from-file=manifests/cpi-vsphere.conf --namespace=kube-system
$ kubectl create -f manifests/cpi-secret.conf
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/cloud-controller-manager-roles.yaml
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/cloud-controller-manager-role-bindings.yaml
$ kubectl apply -f manifests/cloud-provider.yaml
$ kubectl create secret generic vsphere-config-secret --from-file=manifests/csi-vsphere.conf --namespace=kube-system
$ kubectl apply -f manifests/csi-driver-rbac.yaml
$ kubectl create -f manifests/csi-controller.yaml
$ kubectl apply -f manifests/csi-driver-ubuntu.yaml
$ kubectl apply -f manifests/storage-class.yaml
```

After performing these steps, you should be able to provision persistent volumes on VMware vSphere using the newly created Storage Class.

Now, persistent volume requests will not be managed by the out-of-tree CPI/CSI provider.

## Verify driver installation

CSI drivers create Kubernetes CRD objects in order to get information about CSI objects :

- [CSIDriver object details](https://kubernetes-csi.github.io/docs/csi-driver-object.html)
- [CSINode object details](https://kubernetes-csi.github.io/docs/csi-node-object.html)

CSI drivers generate node specific information. Instead of storing this in the Kubernetes Node API Object, a new CSI specific Kubernetes CSINode object was created :

```bash
$ kubectl get csinode
NAME          DRIVERS        AGE
k8s08node1    1              18h
k8s08node2    1              18h
k8s08node3    1              18h
```

> Note all the cluster nodes has a CSI driver.

List/Describe CSI driver :

```bash
$ kubectl get csidrivers
$ kubectl describe csidrivers csi.vsphere.vmware.com
```
