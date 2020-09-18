# Required Variables
variable "region" {}
variable "compartment_ocid" {}
variable "subnet" {}
variable "availability_domain" {}
variable "fault_domain" {}
variable "backup_policy" {}
variable "shape" {}
variable "instance_number" {}
variable "name" {}
variable "ssh_public_key" {}


# Variables with Defaults
variable "fds" {
  type = list
  default = ["FAULT-DOMAIN-1", "FAULT-DOMAIN-2", "FAULT-DOMAIN-3"]
}
# variable "type" {
#   description = "Type of server to build: pia, app, midtier, lb"
#   default = "midtier"
# }
# variable "tier" {
#   description = "What database tier to connect to: dev, tst, prjX, sup, sbx, prd"
# }
variable "instance_count" {
  default = "1"
}
variable "storage" {
  default = "70"
}
variable "volume_mount_directory" {
  default = "/u01"
}
variable "preserve_boot_volume" {
  default = true
}
# SPPS OPC User Key
variable "cloudinit_ps1" {
  default = "cloudinit.ps1"
}
variable "cloudinit_config" {
  default = "cloudinit.yml"
}
variable "setup_ps1" {
  default = "setup.ps1"
}
variable "userdata" {
  default = "userdata"
}
variable "instance_user" {
  default = "opc"
}
variable "ps_user_data" {
    default = ["shared/cloud-init/cloud-init.yaml"] #, "shared/cloud-init/storage.yaml", "shared/cloud-init/reboot.yaml"]
}

variable "enable_public_ip" {
  default = false
}
variable "dns" {
  default = "sppserp.org"
}
variable "enable_public_dns" {
  default = false
}