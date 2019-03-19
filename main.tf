data "aws_iam_policy_document" "assume_role" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "consul" {

  name_prefix        = "consul_role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

data "aws_iam_policy_document" "consul" {


  statement {
    sid       = "AllowSelfAssembly"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "ec2:DescribeVpcs",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
    ]
  }
}

resource "aws_iam_role_policy" "consul" {

  name_prefix = "consul_role"
  role        = "${aws_iam_role.consul.id}"
  policy      = "${data.aws_iam_policy_document.consul.json}"
}

resource "aws_iam_instance_profile" "consul" {

  name_prefix = "consul_role"
  role        = "${aws_iam_role.consul.name}"
}


resource "aws_key_pair" "key" {
  key_name   = "key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

data "template_file" "var" {
  template   = "${file("${path.module}/scripts/start_consul.sh")}"
  depends_on = ["aws_key_pair.key"]

  vars = {
    DOMAIN        = "${var.domain}"
    DCNAME        = "${var.dcname}"
    LOG_LEVEL     = "debug"
    SERVER_COUNT  = 3
    var2          = "$(hostname)"
    IP            = "$(hostname -I)"
  }
}

resource "aws_instance" "consul1" {
  ami                         = "${var.ami["server"]}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${var.subnet_id}"
  key_name                    = "${aws_key_pair.key.id}"
  vpc_security_group_ids      = "${var.security_group_id}"
  iam_instance_profile        = "${aws_iam_instance_profile.consul.id}"
  private_ip                  = "172.31.16.11"
  associate_public_ip_address = true

  tags {
    Name = "consul-server1"
    consul_join = "approved"
  }

  connection {
    user        = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "cat <<EOT > /tmp/scripts/test.sh",
      "${data.template_file.var.rendered}",
      "EOT",
      "sudo bash /tmp/scripts/test.sh",
      "sudo bash /tmp/scripts/keyvalue.sh",
    ]
  }
}

resource "aws_instance" "consul2" {
  ami                         = "${var.ami["server"]}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${var.subnet_id}"
  key_name                    = "${aws_key_pair.key.id}"
  vpc_security_group_ids      = "${var.security_group_id}"
  iam_instance_profile        = "${aws_iam_instance_profile.consul.id}"
  private_ip                  = "172.31.16.12"
  associate_public_ip_address = true

  tags {
    Name = "consul-server2"
    consul_join = "approved"
  }

  connection {
    user        = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "cat <<EOT > /tmp/scripts/test.sh",
      "${data.template_file.var.rendered}",
      "EOT",
      "sudo bash /tmp/scripts/test.sh",
      "sudo bash /tmp/scripts/keyvalue.sh",
    ]
  }
}

resource "aws_instance" "consul3" {
  ami                         = "${var.ami["server"]}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${var.subnet_id}"
  key_name                    = "${aws_key_pair.key.id}"
  vpc_security_group_ids      = "${var.security_group_id}"
  iam_instance_profile        = "${aws_iam_instance_profile.consul.id}"
  private_ip                  = "172.31.16.13"
  associate_public_ip_address = true

  tags {
    Name = "consul-server3"
    consul_join = "approved"
  }

  connection {
    user        = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "cat <<EOT > /tmp/scripts/test.sh",
      "${data.template_file.var.rendered}",
      "EOT",
      "sudo bash /tmp/scripts/test.sh",
      "sudo bash /tmp/scripts/keyvalue.sh",
    ]
  }
}

resource "aws_instance" "client1" {
  ami                         = "${var.ami["client"]}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${var.subnet_id}"
  key_name                    = "${aws_key_pair.key.id}"
  vpc_security_group_ids      = "${var.security_group_id}"
  iam_instance_profile        = "${aws_iam_instance_profile.consul.id}"
  private_ip                  = "172.31.17.11"
  associate_public_ip_address = true

  tags {
    Name = "consul-client1"
    consul_join = "approved"
  }

  connection {
    user        = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "cat <<EOT > /tmp/scripts/test.sh",
      "${data.template_file.var.rendered}",
      "EOT",
      "sudo bash /tmp/scripts/test.sh",
      "sudo bash /tmp/scripts/consul-template.sh",
      "sudo bash /tmp/scripts/conf-dnsmasq.sh",
      "sudo bash /tmp/scripts/check_nginx.sh",
    ]
  }
}

output "server_id1" {
  value = "${aws_instance.consul1.id}"
}

output "server_ip1" {
  value = "${aws_instance.consul1.public_ip}"
}

output "server_id2" {
  value = "${aws_instance.consul2.id}"
}

output "server_ip2" {
  value = "${aws_instance.consul2.public_ip}"
}

output "server_id3" {
  value = "${aws_instance.consul3.id}"
}

output "server_ip3" {
  value = "${aws_instance.consul3.public_ip}"
}

output "client_id1" {
  value = "${aws_instance.client1.id}"
}

output "client_ip1" {
  value = "${aws_instance.client1.public_ip}"
}
