# Required Variables
variable "name" {}
variable "region" {}
variable "compartment_ocid" {}
variable "subnet" {}
variable "availability_domain" {}
variable "fault_domain" {}
variable "backup_policy" {}
variable "shape" {}
variable "instance_number" {}
variable "storage" {}
variable "enable_public_ip" {}
variable "preserve_boot_volume" {}
variable "ssh_public_key" {}

# Optional Variables if using Cloud Shell
variable "tenancy_ocid" {}