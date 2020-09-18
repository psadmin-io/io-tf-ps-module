data "oci_dns_zones" "dns_zones" {
  compartment_id = var.compartment_ocid
  name = var.dns
}

resource "oci_dns_record" "instance_dns" {
    count = var.enable_public_dns ? var.instance_count : 0
    #Required
    zone_name_or_id = var.dns
    domain = "${var.name}.${var.tier}.${var.dns}"
    rtype = "A"
    rdata = oci_core_instance.psinstance[count.index].public_ip
    ttl = "300"
}

output "dns_record" {
  value = oci_dns_record.instance_dns.*.domain
}
output "dns_ip" {
  value = oci_core_instance.psinstance.*.public_ip
}
