# data "oci_core_vcns" "vcn" {
#   compartment_id = var.compartment_ocid
# }

# data "oci_core_subnets" "subnet" {
#   compartment_id = var.compartment_ocid
#   vcn_id         = data.oci_core_vcns.vcn.virtual_networks[0]["id"]

#   filter {
#     name   = "display_name"
#     values = ["${var.subnet}"]
#   }
# }

data "oci_core_subnet" "subnet" {
    #Required
    subnet_id = var.subnet_id
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_volume_backup_policies" "silver" {
  filter {
    name   = "display_name"
    values = ["silver"]
  }
}

data "oci_core_volume_backup_policies" "gold" {
  filter {
    name   = "display_name"
    values = ["gold"]
  }
}

data "oci_core_images" "linux_images" {
    #Required
    compartment_id = var.compartment_ocid

    #Optional
    operating_system = "Oracle Linux"
    operating_system_version = "7.8"
    shape = var.shape
    sort_by = "TIMECREATED"
    sort_order = "DESC"
}