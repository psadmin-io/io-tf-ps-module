# Best Practices for using Terraform with OCI
# https://www.terraform.io/docs/providers/oci/guides/best_practices.html

# Configure the Oracle Cloud Infrastructure provider with an API Key
provider "oci" {
  region           = var.region
}

# OCI Compartment
data "oci_identity_compartment" "compartment" {
  id = var.compartment_ocid
}