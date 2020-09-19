output "oci_compartment_name" {
  value = data.oci_identity_compartment.compartment.name
}

output "oci_subnet" {
  value = data.oci_core_subnet.subnet.id
}

output "availability_domain" {
  value = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain].name
}

output "instance_private_ip" {
  value = oci_core_instance.psinstance.*.private_ip
}

output "instance_public_ip" {
  value = oci_core_instance.psinstance.*.public_ip
}

output "linux_images" {
  value = data.oci_core_images.linux_images.images[0]["base_image_id"]
}