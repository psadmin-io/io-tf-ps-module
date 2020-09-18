module "ps-instance" {
  source = "./ps-instance"

  name                 = var.name
  region               = var.region
  compartment_ocid     = var.compartment_ocid
  subnet               = var.subnet
  availability_domain  = var.availability_domain
  backup_policy        = var.backup_policy
  shape                = var.shape
  instance_number      = var.instance_number
  storage              = var.storage
  enable_public_ip     = var.enable_public_ip
  preserve_boot_volume = var.preserve_boot_volume
  ssh_public_key       = var.ssh_public_key
}