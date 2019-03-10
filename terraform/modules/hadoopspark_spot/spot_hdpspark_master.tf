resource "aws_spot_instance_request" "spot_hdpspark_master" {
    ami = "${var.ami_id}"
    instance_type = "${var.instance_type}"
    key_name = "${var.aws_keypair_name}"
    wait_for_fulfillment = true
    associate_public_ip_address = true
    availability_zone = "${var.availability_zone}"
    count = "${var.spot_hdpspark_master_count}"
    spot_price = "${var.spot_price}"
    security_groups = ["${aws_security_group.hdpsparkstack.name}"]

  tags {
      Name = "spot_hdpspark_master-${count.index}"
      Description = "spot_hdpspark_master-${count.index}"
  }
  ebs_block_device {
    device_name = "/dev/sda1"
    delete_on_termination = true
  }
  volume_tags {
      Name = "spot_hdpspark_master-${count.index}"
  }

  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${self.spot_instance_id} --tags Key=Name,Value=spot_hdpspark_master-${count.index}"

    environment {
      AWS_ACCESS_KEY_ID = "${var.aws_access_key}"
      AWS_SECRET_ACCESS_KEY = "${var.aws_secret_key}"
      AWS_DEFAULT_REGION = "${var.region}"
    }
  }
}



resource "null_resource" "after-spot_hdpspark_master" {
  depends_on = ["aws_spot_instance_request.spot_hdpspark_master"]
  provisioner "local-exec" {
    command = "echo ' spot_hdpspark_masters ${join(",",aws_spot_instance_request.spot_hdpspark_master.*.id)} ${join(",",aws_spot_instance_request.spot_hdpspark_master.*.public_ip)}' >> inventory.txt"
  }
}