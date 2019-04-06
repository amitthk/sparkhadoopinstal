output "spot_hdpspark_master" {
  value = "${aws_spot_instance_request.spot_hdpspark_master.*.public_ip}"
}
output "spot_hdpspark_worker" {
  value = "${aws_spot_instance_request.spot_hdpspark_worker.*.public_ip}"
}
output "spot_hdpspark_gateway" {
  value = "${aws_spot_instance_request.spot_hdpspark_gateway.*.public_ip}"
}