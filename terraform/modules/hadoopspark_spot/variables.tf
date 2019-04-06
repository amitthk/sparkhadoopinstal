provider "aws" {
    region = "${var.region}"
    access_key ="${var.aws_access_key}"
    secret_key ="${var.aws_secret_key}"
}

variable "spot_price" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_keypair_name" {}
variable "region" {}
variable "availability_zone" {}
variable "instance_type" {}
variable "vpc_id" {}
variable "hadoop_stack_name" {}
variable "ami_id" {}
variable "vpc_cidr" {}
variable "public_subnets_cidr_blocks" {}
variable "private_subnets_cidr_blocks" {}
variable "spot_hdpspark_master_count" { default = 1 }
variable "spot_hdpspark_worker_count" { default = 1 }
variable "spot_hdpspark_gateway_count" { default = 1}
variable "ingress_from_port" {}
variable "ingress_to_port" {}