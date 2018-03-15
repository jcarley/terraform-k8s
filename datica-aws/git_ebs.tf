
resource "aws_volume_attachment" "git_ebs_att" {
  count = "${var.count}"
  device_name = "${lookup(var.ebs_device_name, "git")}"
  volume_id = "${element(aws_ebs_volume.git_volume.*.id, count.index)}"
  instance_id = "${element(aws_instance.master.*.id, count.index)}"
  force_detach = true
}

resource "aws_ebs_volume" "git_volume" {
  count = "${var.count}"
  availability_zone = "${var.aws_region}b"
  size = "${var.ebs_volume_size}"
  type = "${var.ebs_volume_type}"
  encrypted = true
  tags {
    Name = "${var.name}"
  }
}

resource "null_resource" "mkfs_git" {
  count = "${var.count}"

  triggers {
    volume_attachment = "${element(aws_volume_attachment.git_ebs_att.*.id, count.index)}"
  }

  connection {
    user = "ubuntu"
    host = "${element(aws_instance.master.*.public_ip, count.index)}"
  }

  provisioner "file" {
    source      = "scripts/mountdrive.sh"
    destination = "/tmp/mountdrive.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/mountdrive.sh",
      "/tmp/mountdrive.sh ${lookup(var.ebs_device_name, "git")} /data/git",
    ]
  }
}

