# Kubernetes cluster variables

variable "cluster_name" {
  type        = string
  description = "(Required) The name of the cluster"
}

variable "cluster_description" {
  type        = string
  description = "(Optional) The description of the cluster. Default value is ''"
  default     = ""
}

variable "cluster_csi_support" {
  type        = bool
  description = "(Optional) Wether or not the cluster has support for CSI driver. Changing this value will force a cluster re-creation. Default value is true."
  default     = true
}

# VSphere provider information

variable "cloud_credential_name" {
  type        = string
  description = "(Required) The name of the Cloud Credential"
}

variable "cloud_credential_description" {
  type        = string
  description = "(Optional) The description of the Cloud Credentials. Default value is ''"
  default     = ""
}

variable "cloud_credential_username" {
  type        = string
  description = "(Required) The description of the Cloud Credentials. Default value is ''"
}

variable "cloud_credential_password" {
  type        = string
  description = "(Required) vSphere password for vCenter"
  sensitive   = true
}

variable "cloud_credential_vcenter" {
  type        = string
  description = "(Required) vSphere IP/hostname for vCenter"
}

variable "cloud_credential_vcenter_port" {
  type        = string
  description = "(Optional) vSphere port for vCenter. Default is 443"
  default     = "443"
}

variable "vcenter_datacenter_name" {
  type        = string
  description = "(Required) The name of the datacenter in the vCenter."
}

variable "vcenter_datastore" {
  type        = string
  description = "(Required) The path of the datastore in the vCenter."
}

variable "vcenter_folder" {
  type        = string
  description = "(Required) The folder in the vCenter to put nodes into."
}

variable "vcenter_resourcepool_path" {
  type        = string
  description = "(Required) The folder in the vCenter to put nodes into."
}

# Cluster template configuration

variable "cluster_template_name" {
  type        = string
  description = "(Required) The cluster template name"
}

variable "cluster_template_revision" {
  type        = string
  description = "(Optional) Cluster template revisions. Default value is 'default'"
  default     = "default"
}

variable "cluster_template_kubernetes_version" {
  type        = string
  description = "(Required) Cluster template Kubernetes version"
}

variable "cluster_template_ingress_provider" {
  type        = string
  description = "(Required) Cluster template ingress provider"
}

variable "cluster_template_network_plugin" {
  type        = string
  description = "(Required) Cluster template network plugin"
}

variable "cluster_template_kubelet_extra_binds" {
  type        = list(string)
  description = "(Optional) Cluster template additional volume binds for Kubelet"
  default     = []
}

# Admin user

variable "admin_user" {
  type        = string
  description = "(Optional) The admin username for this cluster. Default is the cluster name prefixed with 'admin'."
  default     = "admin"
}

variable "admin_password" {
  type        = string
  description = "(Required) The admin password"
  sensitive   = true
}

# Other users

variable "users" {
  type        = list(map(any))
  description = "(Optional) A list of additional users to create within the cluster."
  default     = []
}

# Node template & node pool

variable "node_templates" {
  type        = map(any)
  description = "(Optional) Rancher v2 Node Template resource"
  default     = {}
}

variable "node_pools" {
  type        = map(any)
  description = "(Optional) Rancher v2 Node Pool resource"
  default     = {}
}

# Kubernetes manifests

variable "kubernetes_manifests" {
  type        = list(string)
  description = "(Optional) Kubernetes manifests to apply"
  default     = []
}
