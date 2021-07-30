# CLUSTER TEMPLATE & CLUSTER

resource "rancher2_cluster_template" "nocsi" {
  name = "${ var.cluster_template_name }-nocsi"

  template_revisions {
    name    = var.cluster_template_revision
    enabled = true
    default = true
    cluster_config {
      rke_config {
        kubernetes_version = var.cluster_template_kubernetes_version
        ingress { provider = var.cluster_template_ingress_provider }
        network {
          plugin = var.cluster_template_network_plugin
          mtu = 0
          options = {
            flannel_backend_type = "vxlan"
          }
        }
        ignore_docker_version = true
        cloud_provider {
          name = "vsphere"
          vsphere_cloud_provider {
            global {
              insecure_flag = true
              soap_roundtrip_count = 0
            }
            virtual_center {
                name = var.cloud_credential_vcenter
                datacenters = var.vcenter_datacenter_name
                port = var.cloud_credential_vcenter_port
                soap_roundtrip_count = 0
                user = var.cloud_credential_username
                password = var.cloud_credential_password
            }
            workspace {
              datacenter = var.vcenter_datacenter_name
              default_datastore = var.vcenter_datastore
              folder = var.vcenter_folder
              resourcepool_path = var.vcenter_resourcepool_path
              server = var.cloud_credential_vcenter
            }
          }
        }
        services {
          etcd {
            creation   = "12h"
            retention  = "72h"
            snapshot   = false
            extra_args = tomap({ "election-timeout" = "5000", "heartbeat-interval" = "500" })
            backup_config {
              enabled        = true
              interval_hours = 12
              retention      = 6
              safe_timestamp = false
              timeout        = 0
            }
          }
          kube_api {
            secrets_encryption_config { enabled = false }
          }
          #kubelet {
          #  extra_binds = var.cluster_template_kubelet_extra_binds
          #  extra_args  = {
          #    cloud-provider  = "external"
          #  }
          #}
        }
      }
    }
  }
}

resource "rancher2_cluster_template" "csi" {
  name = "${ var.cluster_template_name }-csi"

  template_revisions {
    name    = var.cluster_template_revision
    enabled = true
    default = true
    cluster_config {
      rke_config {
        kubernetes_version = var.cluster_template_kubernetes_version
        ingress { provider = var.cluster_template_ingress_provider }
        network {
          plugin = var.cluster_template_network_plugin
          mtu = 0
          options = {
            flannel_backend_type = "vxlan"
          }
        }
        ignore_docker_version = true
        cloud_provider {
          name = "vsphere"
          vsphere_cloud_provider {
            global {
              insecure_flag = true
              soap_roundtrip_count = 0
            }
            virtual_center {
                name = var.cloud_credential_vcenter
                datacenters = var.vcenter_datacenter_name
                port = var.cloud_credential_vcenter_port
                soap_roundtrip_count = 0
                user = var.cloud_credential_username
                password = var.cloud_credential_password
            }
            workspace {
              datacenter = var.vcenter_datacenter_name
              default_datastore = var.vcenter_datastore
              folder = var.vcenter_folder
              resourcepool_path = var.vcenter_resourcepool_path
              server = var.cloud_credential_vcenter
            }
          }
        }
        services {
          etcd {
            creation   = "12h"
            retention  = "72h"
            snapshot   = false
            extra_args = tomap({ "election-timeout" = "5000", "heartbeat-interval" = "500" })
            backup_config {
              enabled        = true
              interval_hours = 12
              retention      = 6
              safe_timestamp = false
              timeout        = 0
            }
          }
          kube_api {
            secrets_encryption_config { enabled = false }
          }
          kubelet {
            extra_binds = var.cluster_template_kubelet_extra_binds
            extra_args  = {
              cloud-provider  = "external"
            }
          }
        }
      }
    }
  }
}

resource "rancher2_cluster" "this" {
  name        = var.cluster_name
  description = var.cluster_description

  cluster_template_id          = var.cluster_csi_support ? rancher2_cluster_template.csi.id : rancher2_cluster_template.nocsi.id
  cluster_template_revision_id = var.cluster_csi_support ? rancher2_cluster_template.csi.default_revision_id : rancher2_cluster_template.nocsi.default_revision_id
}

# ADMIN USER

resource "rancher2_user" "admin" {
  name      = "Admin for ${rancher2_cluster.this.name}"
  username  = "${var.admin_user}-${rancher2_cluster.this.name}"
  password  = var.admin_password
  enabled   = true
}

resource "rancher2_global_role_binding" "admin" {
  name            = "${var.admin_user}-${rancher2_cluster.this.name}-user-base"
  global_role_id  = "user-base"
  user_id         = rancher2_user.admin.id
}

resource "rancher2_role_template" "clusterrole" {
  name              = "Scalair's clients"
  description       = "Admin user of their own cluster"
  context           = "cluster"
  default_role      = false
  administrative    = true
  role_template_ids = [
    "cluster-member",
    "projects-view",
  ]
}

resource "rancher2_cluster_role_template_binding" "clusterrolebinding" {
  name             = "cluster-owner"
  cluster_id       = rancher2_cluster.this.id
  role_template_id = rancher2_role_template.clusterrole.id
  user_id          = rancher2_user.admin.id
}

resource "rancher2_project_role_template_binding" "admin-default" {
  name              = "admin-default"
  project_id        = data.rancher2_project.default.id
  role_template_id  = "project-owner"
  user_id           = rancher2_user.admin.id
}

resource "rancher2_project_role_template_binding" "admin-system" {
  name              = "admin-system"
  project_id        = data.rancher2_project.system.id
  role_template_id  = "project-owner"
  user_id           = rancher2_user.admin.id
}

# OTHER USERS

resource "rancher2_user" "user" {
  count     = length(var.users)

  name      = "User ${var.users[count.index].username} on ${rancher2_cluster.this.name}"
  username  = "${var.users[count.index].username}-${rancher2_cluster.this.name}"
  password  = var.users[count.index].password
  enabled   = var.users[count.index].enabled
}

# OTHER USERS PRIVILEGES

locals {
  cluster_privileges = flatten([
    for i, user in var.users: [
      for k, privilege in user.cluster_privileges: {
        privilege = privilege
        username  = user.username
        index     = i
      }
    ]
  ])

  project_privileges = flatten([
    for i, user in var.users: [
      for k, prjprivilege in user.project_privileges: [
        for p, priv in prjprivilege.privileges:
        {
          project_name  = prjprivilege.project_name
          project_id    = local.rancher_projects[prjprivilege.project_name]
          privilege     = priv
          username      = user.username
          index         = i
        }
      ]
    ]
  ])

  rancher_projects = { for i, project in data.rancher2_project.projects: project.name => project.id }

  rancher_users = { for i, user in data.rancher2_user.users: user.username => user.id }
}

resource "rancher2_cluster_role_template_binding" "userclusterrolebinding" {
  for_each          = { for k, v in local.cluster_privileges: k => v }

  name              = "${rancher2_cluster.this.id}-${each.value.username}-${each.value.privilege}"
  cluster_id        = rancher2_cluster.this.id
  role_template_id  = each.value.privilege
  user_id           = local.rancher_users["${each.value.username}-${rancher2_cluster.this.name}"]
}

resource "rancher2_project_role_template_binding" "userprojectrolebinding" {
  for_each          = { for k, v in local.project_privileges: k => v }

  name              = lower("${each.value.username}-${rancher2_cluster.this.id}-${each.value.project_name}-${each.value.privilege}")
  project_id        = each.value.project_id
  role_template_id  = each.value.privilege
  user_id           = local.rancher_users["${each.value.username}-${rancher2_cluster.this.name}"]
}

# CLOUD CREDENTIAL

resource "rancher2_cloud_credential" "this" {
  name        = var.cloud_credential_name
  description = var.cloud_credential_description
  vsphere_credential_config {
    username     = var.cloud_credential_username
    password     = var.cloud_credential_password
    vcenter      = var.cloud_credential_vcenter
    vcenter_port = var.cloud_credential_vcenter_port
  }
}

# NODE TEMPLATES & NODE POOLS

resource "rancher2_node_template" "this" {
  for_each = var.node_templates

  name                = each.key
  engine_install_url  = each.value.engine_install_url
  cloud_credential_id = rancher2_cloud_credential.this.id

  labels = each.value.labels

  vsphere_config {
    cfgparam      = each.value.cfgparam
    cpu_count     = each.value.cpu_count
    memory_size   = each.value.memory_size
    disk_size     = each.value.disk_size
    creation_type = each.value.creation_type
    cloud_config  = each.value.cloud_config
    datacenter    = each.value.datacenter
    folder        = each.value.folder
    clone_from    = each.value.clone_from
    datastore     = each.value.datastore
    pool          = each.value.pool
    network       = each.value.network
    tags          = each.value.tags
  }
}

resource "rancher2_node_pool" "this" {
  for_each          = var.node_pools

  cluster_id        = rancher2_cluster.this.id
  node_template_id  = rancher2_node_template.this[each.value.template_name].id

  name              = each.key
  hostname_prefix   = each.value.hostname_prefix
  quantity          = each.value.quantity
  control_plane     = contains(each.value.roles, "control_plane")
  etcd              = contains(each.value.roles, "etcd")
  worker            = contains(each.value.roles, "worker")
}
