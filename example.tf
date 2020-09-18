module "psdmo01" {
  source = "./ps-instance"

  name                 = "psdmo"
  region               = "us-ashburn-1"
  compartment_ocid     = "ocid1.compartment.oc1..xxx"
  subnet               = "DMZ Subnet"
  availability_domain  = "1"
  backup_policy        = "silver"
  shape                = "VM.Standard2.1"
  instance_number      = "01"
  storage              = "100"
  enable_public_ip     = true
  preserve_boot_volume = false
  ssh_public_key       = "ssh-rsa ..."
}