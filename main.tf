resource "aws_key_pair" "key" {
  key_name   = "key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

data "template_file" "var" {
  template = "${file("var.sh")}"

  vars = {
    DOMAIN = "$${var.domain}"
    DCNAME = "$${var.dcname}"
  }
}

resource "aws_instance" "consul1" {
  ami                         = "${var.ami["server"]}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${var.subnet_id}"
  key_name                    = "${aws_key_pair.key.id}"
  vpc_security_group_ids      = "${var.security_group_id}"
  private_ip                  = "172.31.16.11"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.var.rendered}"

  tags {
    Name = "consul-server1"
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
      "sudo bash /tmp/scripts/start_consul.sh",
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
  private_ip                  = "172.31.16.12"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.var.rendered}"

  tags {
    Name = "consul-server2"
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
      "sudo bash /tmp/scripts/start_consul.sh",
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
  private_ip                  = "172.31.16.13"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.var.rendered}"

  tags {
    Name = "consul-server3"
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
      "sudo bash /tmp/scripts/start_consul.sh",
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
  private_ip                  = "172.31.17.11"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.var.rendered}"

  tags {
    Name = "consul-client1"
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
      "sudo bash /tmp/scripts/start_consul.sh",
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
