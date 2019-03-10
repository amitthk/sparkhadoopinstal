resource "aws_spot_instance_request" "spot_hdpspark_worker" {
    ami = "${var.ami_id}"
    instance_type = "${var.instance_type}"
    key_name = "${var.aws_keypair_name}"
    count = "${var.spot_hdpspark_worker_count}"
    availability_zone = "${var.availability_zone}"
    wait_for_fulfillment = true
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.hdpsparkstack.name}"]

  tags {
      Name = "spot_hdpspark_worker-${count.index}"
      Description = "spot_hdpspark_worker ${count.index}"
  }
  ebs_block_device {
    device_name = "/dev/sda1"
    delete_on_termination = true
  }
  volume_tags {
      Name = "spot_hdpspark_worker-${count.index}"
  }


  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${self.spot_instance_id} --tags Key=Name,Value=spot_hdpspark_worker-${count.index}"

    environment {
      AWS_ACCESS_KEY_ID = "${var.aws_access_key}"
      AWS_SECRET_ACCESS_KEY = "${var.aws_secret_key}"
      AWS_DEFAULT_REGION = "${var.region}"
    }
  }
}
resource "null_resource" "after-spot_hdpspark_worker" {
  depends_on = ["aws_spot_instance_request.spot_hdpspark_worker"]
  provisioner "local-exec" {
    command = "echo ' spot_hdpspark_workers ${join(",",aws_spot_instance_request.spot_hdpspark_worker.*.id)} ${join(",",aws_spot_instance_request.spot_hdpspark_worker.*.public_ip)}' >> inventory.txt"
  }
}