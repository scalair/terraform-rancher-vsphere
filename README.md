# terraform-vsphere-rancher

![Apache 2.0 Licence](https://img.shields.io/hexpm/l/plug.svg) ![Terraform](https://img.shields.io/badge/terraform->=0.15-green.svg)

Terraform module that manages Kubernetes clusters through an existing [rancher server](https://rancher.com/docs/rancher/v2.5/en/).

## Prerequisites

- `terraform` >= 0.15
- an existing rancher server
  - rancher's url
  - rancher's admin account with sufficient privileges
  - access & secret tokens of rancher's admin account : [how to create them ?](docs/create_access_and_secret_tokens.md)
- an existing VMware VCenter Server
  - vcenter's url
  - vcenter's username/password with sufficient privileges

## Admin user

The terraform module automatically creates an admin with full privileges within the cluster. This is the purpose of `admin_user` and `admin_password`.

Once created, the `admin_user` is suffixed with the defined `cluster_name`.

Let's imagine you've built with :

- `admin_user` : "admin"
- `cluster_name` : "k8spoc01"

Then, the created admin username is `admin-k8spoc01`.

## Usage

Standard example (see the next example for persistent storage) :

```yaml
module "rancher_k8s" {
  source = "github.com/scalair/terraform-rancher-vsphere"

  cluster_template_revision = "v3" # must be changed if any value from the template object is changed
  cluster_template_name = "default"
  cluster_template_kubernetes_version = "v1.19.7-rancher1-1"
  cluster_template_ingress_provider = "nginx"
  cluster_template_network_plugin = "canal"

  cluster_name        = "k8s-poc01"
  cluster_description = "POC Rancher cluster"
  cluster_csi_support = false

  cloud_credential_name         = "neon"
  cloud_credential_description  = "vSphere Cluster"
  cloud_credential_username     = xxx
  cloud_credential_password     = xxx
  cloud_credential_vcenter      = xxx
  cloud_credential_vcenter_port = xxx

  vcenter_datacenter_name     = "DC"
  vcenter_datastore           = "ds:///vmfs/volumes/2abe1337-25e31337/"
  vcenter_folder              = "/DC/vm/MYFOLDER"
  vcenter_resourcepool_path   = "host/CLUSTER01/Resources"
  
  admin_user     = "admin"
  admin_password = xxx

  users = [
    {
      username  = "xat"
      password  = "xxx"
      enabled   = true
    },
    {
      username  = "blakelead"
      password  = "xxx"
      enabled   = true
    }
  ]

  node_templates = {
    "worker1-4-16-ubuntu" = {
      engine_install_url = "https://releases.rancher.com/install-docker/19.03.sh"
      labels = {
        "ssd"        = "true"
      }
      cfgparam = ["disk.enableUUID=TRUE"]
      cpu_count = "4"
      memory_size = "16384"
      disk_size = "80000"
      creation_type = "template"
      cloud_config = file("config/cloud-config.yaml")
      datacenter = "/DC"
      folder = "/DC/vm/C1337/"
      clone_from = "/DC/vm/C1337/template-ubuntu2004"
      datastore = "/DC/datastore/C1337_DATASTORE"
      pool = "/DC/host/STD_OTH_K8S/Resources"
      network = ["/DC/network/C1337_K8S_BACK_65738"]
      tags = [
        "urn:vmomi:InventoryServiceTag:e6db455b-8454-42e7-a175-5d8c6a2e537d:GLOBAL"
      ]
    }
  }

  node_pools = {
    "np-xb55s" = {
      hostname_prefix = "k8spoc01node1-"
      roles           = ["control_plane", "etcd", "worker"]
      quantity        = 1
      template_name   = "worker1-4-16-ubuntu"
    },
    "np-c5lrk" = {
      hostname_prefix = "k8spoc01node2-"
      roles           = ["control_plane", "etcd", "worker"]
      quantity        = 1
      template_name   = "worker1-4-16-ubuntu"
    },
    "np-k52vq" = {
      hostname_prefix = "k8spoc01node3-"
      roles           = ["control_plane", "etcd", "worker"]
      quantity        = 1
      template_name   = "worker1-4-16-ubuntu"
    }
  }
}
```

Example with CSI support :

```yaml
module "rancher_k8s" {
  source = "github.com/scalair/terraform-rancher-vsphere"

  cluster_template_revision = "v3" # must be changed if any value from the template object is changed
  cluster_template_name = "default"
  cluster_template_kubernetes_version = "v1.19.7-rancher1-1"
  cluster_template_ingress_provider = "nginx"
  cluster_template_network_plugin = "canal"
  cluster_template_kubelet_extra_binds = [
      "/var/lib/csi/sockets/pluginproxy/csi.vsphere.vmware.com:/var/lib/csi/sockets/pluginproxy/csi.vsphere.vmware.com:rshared",
      "/csi:/csi:rshared"
  ]

  cluster_name        = "k8s-poc01"
  cluster_description = "POC Rancher cluster"
  cluster_csi_support = true

  cloud_credential_name         = "neon"
  cloud_credential_description  = "vSphere Cluster"
  cloud_credential_username     = xxx
  cloud_credential_password     = xxx
  cloud_credential_vcenter      = xxx
  cloud_credential_vcenter_port = xxx

  vcenter_datacenter_name     = "DC"
  vcenter_datastore           = "ds:///vmfs/volumes/2abe1337-25e31337/"
  vcenter_folder              = "/DC/vm/MYFOLDER"
  vcenter_resourcepool_path   = "host/CLUSTER01/Resources"

  admin_user     = "admin"
  admin_password = xxx

  node_templates = {
    "worker1-4-16-ubuntu" = {
      engine_install_url = "https://releases.rancher.com/install-docker/19.03.sh"
      labels = {
        "ssd"        = "true"
      }
      cfgparam = ["disk.enableUUID=TRUE"]
      cpu_count = "4"
      memory_size = "16384"
      disk_size = "80000"
      creation_type = "template"
      cloud_config = file("config/cloud-config.yaml")
      datacenter = "/DC"
      folder = "/DC/vm/C1337/"
      clone_from = "/DC/vm/C1337/template-ubuntu2004"
      datastore = "/DC/datastore/C1337_DATASTORE"
      pool = "/DC/host/STD_OTH_K8S/Resources"
      network = ["/DC/network/C1337_K8S_BACK_65738"]
      tags = [
        "urn:vmomi:InventoryServiceTag:e6db455b-8454-42e7-a175-5d8c6a2e537d:GLOBAL"
      ]
    }
  }

  node_pools = {
    "np-xb55s" = {
      hostname_prefix = "k8spoc01node1-"
      roles           = ["control_plane", "etcd", "worker"]
      quantity        = 1
      template_name   = "worker1-4-16-ubuntu"
    },
    "np-c5lrk" = {
      hostname_prefix = "k8spoc01node2-"
      roles           = ["control_plane", "etcd", "worker"]
      quantity        = 1
      template_name   = "worker1-4-16-ubuntu"
    },
    "np-k52vq" = {
      hostname_prefix = "k8spoc01node3-"
      roles           = ["control_plane", "etcd", "worker"]
      quantity        = 1
      template_name   = "worker1-4-16-ubuntu"
    }
  }
}
```

## Persistent storage

In order to enable persistent storage, please [read CSI/CPI documentation](docs/csi/persistent_storage_with_csi_driver.md)

## Versioning

For the versions available, see the [tags on this repository](https://github.com/scalair/terraform-rancher-vsphere/tags).

Additionaly you can see what change in each version in the [CHANGELOG.md](CHANGELOG.md) file.

## Authors

- **blakelead** - [blakelead](https://github.com/blakelead)
- **xat** - [xat](https://github.com/Xat59)
- **scalair** - [Scalair](https://github.com/scalair)
