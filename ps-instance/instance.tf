resource "tls_private_key" "public_private_key_pair" {
  algorithm   = "RSA"
}

resource "oci_core_instance" "psinstance" {
    count = var.instance_count
    
    #Required
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain].name
    fault_domain        = var.fds[var.fault_domain]
    compartment_id      = var.compartment_ocid
    shape               = var.shape

    lifecycle {
      ignore_changes = [source_details, metadata]
    }

    #Optional
    create_vnic_details {
        #Required
        subnet_id = data.oci_core_subnet.subnet.id

        #Optional
        assign_public_ip = var.enable_public_ip ? true : false
        # private_ip       = element(var.ip_address, count.index)
        hostname_label   = "${var.name}${count.index + var.instance_number}"
    }

    display_name   = "${var.name}${count.index + var.instance_number}"
    hostname_label = "${var.name}${count.index + var.instance_number}"
    
    source_details {
        #Required
        source_id   = data.oci_core_images.linux_images.images[0].id
        source_type = "image"
    }
    
    preserve_boot_volume = var.preserve_boot_volume
    
    metadata = {
      ssh_authorized_keys = join("\n", [var.ssh_public_key, tls_private_key.public_private_key_pair.public_key_openssh])
      user_data           = "${base64encode(join("", [for file in var.ps_user_data : file("${path.module}/${file}")]))}"
    }
}

resource "null_resource" "psinstance_provision" {
  count = var.instance_count
  depends_on = [oci_core_instance.psinstance, oci_core_volume.psinstance_storage, oci_core_volume_attachment.psinstance_storage_attachment]

  #Connect the null_resource with the instance so the provisioner is re-run if the instance is rebuilt
  triggers = {
    ps_ids = "${join(",", oci_core_instance.psinstance.*.id)}"
  }

  connection {
    host        = var.enable_public_ip ? element(oci_core_instance.psinstance.*.public_ip, count.index) : element(oci_core_instance.psinstance.*.private_ip, count.index)
    user        = "opc"
    private_key = tls_private_key.public_private_key_pair.private_key_pem
  }

  # provisioner "file" {
  #   source      = "${path.module}/shared/provision.sh"
  #   destination = "/tmp/provision.sh"
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #       "mkdir -p /tmp/users",
  #     ]
  # }

  # provisioner "file" {
  #   source      = "${path.module}/shared/users"
  #   destination = "/tmp/"
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #       "chmod +x /tmp/provision.sh;",
  #       "sudo /tmp/provision.sh ${var.type} ${var.tier} | tee /tmp/provision.log",
  #     ]
  # }
}

resource "oci_core_volume" "psinstance_storage" {
  count = var.instance_count

  #Required
  availability_domain = oci_core_instance.psinstance[0].availability_domain
  compartment_id = var.compartment_ocid

  #Optional
  display_name = "${var.name}${count.index + 1} storage"
  size_in_gbs = var.storage
}

resource "oci_core_volume_attachment" "psinstance_storage_attachment" {
  count = var.instance_count

  #Required
  attachment_type = "iscsi"
  use_chap        = true
  instance_id     = element(oci_core_instance.psinstance.*.id, count.index)
  volume_id       = element(oci_core_volume.psinstance_storage.*.id, count.index)
  # Not used with iscsi attachments
  # device = "/dev/oracleoci/oraclevdb"

  connection {
    type        = "ssh"
    host        = element(oci_core_instance.psinstance.*.private_ip, count.index)
    user        = "opc"
    private_key = tls_private_key.public_private_key_pair.private_key_pem
  }
  
  # https://medium.com/oracledevs/managing-oracle-cloud-infrastructure-iscsi-block-volume-attachments-with-terraform-97726691b842
  # register and connect the iSCSI block volume
  provisioner "remote-exec" {
    inline = [
      "sudo iscsiadm -m node -o new -T ${self.iqn} -p ${self.ipv4}:${self.port}",
      "sudo iscsiadm -m node -o update -T ${self.iqn} -n node.startup -v automatic",
      "sudo iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -o update -n node.session.auth.authmethod -v CHAP",
      "sudo iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -o update -n node.session.auth.username -v ${self.chap_username}",
      "sudo iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -o update -n node.session.auth.password -v ${self.chap_secret}",
      "sudo iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -l",
    ]
  }
  # initialize partition and file system
  provisioner "remote-exec" {
    inline = [
      "set -x",
      "export DEVICE_ID=ip-${self.ipv4}:${self.port}-iscsi-${self.iqn}-lun-1",
      "export HAS_PARTITION=$(sudo partprobe -d -s /dev/disk/by-path/$${DEVICE_ID} | wc -l)",
      "if [ $HAS_PARTITION -eq 0 ] ; then",
      "  (echo o; echo n; echo p; echo 1; echo ''; echo ''; echo w) | sudo fdisk /dev/disk/by-path/$${DEVICE_ID}",
      "  while [[ ! -e /dev/disk/by-path/$${DEVICE_ID}-part1 ]] ; do sleep 1; done",
      "  sudo mkfs.ext4 /dev/disk/by-path/$${DEVICE_ID}-part1",
      "fi",
    ]
  }
  # mount the partition
  provisioner "remote-exec" {
    inline = [
      "set -x",
      "export DEVICE_ID=ip-${self.ipv4}:${self.port}-iscsi-${self.iqn}-lun-1",
      "sudo mkdir -p ${var.volume_mount_directory}",
      "export UUID=$(sudo /sbin/blkid -s UUID -o value /dev/disk/by-path/$${DEVICE_ID}-part1)",
      # "export UUID=$(sudo blkid | grep /dev/disk/by-path/$${DEVICE_ID}-part1 | awk '{print $2}')",
      "echo 'UUID='$${UUID}' ${var.volume_mount_directory} auto defaults,_netdev,nofail 0 2' | sudo tee -a /etc/fstab",
      "sudo mount -a",
    ]
  }
  # unmount and disconnect on destroy
  # New Terraform versions error with destroy-time provisions that use connection information 
  #    without "self." references. This provision was referencing the instance to get the 
  #    private_ip, so leaving this off for now.
  # provisioner "remote-exec" {
  #   when       = destroy
  #   on_failure = continue
  #   inline = [
  #     "set -x",
  #     "export DEVICE_ID=ip-${self.ipv4}:${self.port}-iscsi-${self.iqn}-lun-1",
  #     "export UUID=$(sudo /sbin/blkid -s UUID -o value /dev/disk/by-path/$${DEVICE_ID}-part1)",
  #     # "export UUID=$(sudo blkid | grep /dev/disk/by-path/$${DEVICE_ID}-part1 | awk '{print $2}')",
  #     "sudo umount ${var.volume_mount_directory}",
  #     "if [[ $UUID ]] ; then",
  #     "  sudo sed -i.bak '\\@^UUID='$${UUID}'@d' /etc/fstab",
  #     "fi",
  #     "sudo iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -u",
  #     "sudo iscsiadm -m node -o delete -T ${self.iqn} -p ${self.ipv4}:${self.port}",
  #   ]
  # }
}

resource "oci_core_volume_backup_policy_assignment" "psinstance_storage" {
  count = var.instance_count

  asset_id = element(oci_core_volume.psinstance_storage.*.id, count.index)
  policy_id = data.oci_core_volume_backup_policies.gold.volume_backup_policies[0].id
}

resource "oci_core_volume_backup_policy_assignment" "psinstance_boot" {
  count = var.instance_count

  asset_id = element(oci_core_instance.psinstance.*.boot_volume_id, count.index)
  policy_id = data.oci_core_volume_backup_policies.silver.volume_backup_policies[0].id
}

