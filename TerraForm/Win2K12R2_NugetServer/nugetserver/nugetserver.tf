resource "aws_instance" "nuget_server" {
    ami = "ami-50e67823"
    instance_type = "${var.nuget_instance_type}"
    availability_zone = ""
    user_data = "${template_file.nuget_server_userdata.rendered}"
    subnet_id = "${var.subnet_id}"
    associate_public_ip_address = true
    vpc_security_group_ids = ["${aws_security_group.nuget_server.id}"]
    monitoring = true
    key_name = "${var.nuget_server_keypair}"
    tags {
        Name = "NuGet"
        description = "Collinson Group NuGet Server"
        cost_code = "${var.tag_cost_code}"
        environment = "${var.tag_environment}"
        owner = "${var.tag_owner}"
    }
    lifecycle {
      prevent_destroy = "false"
    }
}

resource "aws_security_group" "nuget_server" {
  name = "sg_NuGet_server"
  description = "Nuget server security group"
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "sg_NuGet_server"
    Description = "Nuget server security group"
    cost_code = "${var.tag_cost_code}"
    environment = "${var.tag_environment}"
    owner = "${var.tag_owner}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "nuget_server_https_in" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.nuget_server.id}"
}

resource "aws_security_group_rule" "nuget_server_http_in" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.nuget_server.id}"
}

resource "aws_security_group_rule" "nuget_server_rdp_in" {
  type = "ingress"
  from_port = 3389
  to_port = 3389
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.nuget_server.id}"
}

resource "aws_security_group_rule" "nuget_server_out" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.nuget_server.id}"
}

