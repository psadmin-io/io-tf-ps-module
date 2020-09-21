module "ps-instance" {
  source = "./ps-instance"
  # source = "github.com/psadmin-io/io-tf-ps-module"

  name                 = var.name
  tenancy_ocid         = var.tenancy_ocid
  region               = var.region
  compartment_ocid     = var.compartment_ocid
  subnet_id            = var.subnet_id
  availability_domain  = var.availability_domain
  fault_domain         = var.fault_domain
  backup_policy        = var.backup_policy
  shape                = var.shape
  instance_number      = var.instance_number
  storage              = var.storage
  enable_public_ip     = var.enable_public_ip
  preserve_boot_volume = var.preserve_boot_volume
  ssh_public_key       = var.ssh_public_key
}

output "public_ip" {
  value = module.ps-instance.instance_public_ip
}