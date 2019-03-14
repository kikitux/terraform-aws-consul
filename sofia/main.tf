resource "aws_key_pair" "key" {
  key_name   = "key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "consul1" {
  ami                         = "${var.ami["server"]}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.key.id}"
  vpc_security_group_ids      = "${var.security_group_id}"
  private_ip                  = "172.31.16.11"
  associate_public_ip_address = true

  tags {
    Name = "consul-server1"
  }

  connection {
    user        = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "sofia/scripts"
    destination = "/var/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /var/tmp/scripts/start_consul.sh",
      "sudo bash /var/tmp/scripts/keyvalue.sh",
    ]
  }
}

resource "aws_instance" "consul2" {
  ami                         = "${var.ami["server"]}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.key.id}"
  vpc_security_group_ids      = "${var.security_group_id}"
  private_ip                  = "172.31.16.12"
  associate_public_ip_address = true

  tags {
    Name = "consul-server2"
  }

  connection {
    user        = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "sofia/scripts"
    destination = "/var/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /var/tmp/scripts/start_consul.sh",
      "sudo bash /var/tmp/scripts/keyvalue.sh",
    ]
  }
}

resource "aws_instance" "consul3" {
  ami                         = "${var.ami["server"]}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.key.id}"
  vpc_security_group_ids      = "${var.security_group_id}"
  private_ip                  = "172.31.16.13"
  associate_public_ip_address = true

  tags {
    Name = "consul-server3"
  }

  connection {
    user        = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "sofia/scripts"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /var/tmp/scripts/start_consul.sh",
      "sudo bash /var/tmp/scripts/keyvalue.sh",
    ]
  }
}

resource "aws_instance" "client1" {
  ami                         = "${var.ami["client"]}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.key.id}"
  vpc_security_group_ids      = "${var.security_group_id}"
  private_ip                  = "172.31.17.11"
  associate_public_ip_address = true

  tags {
    Name = "consul-client1"
  }

  connection {
    user        = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "sofia/scripts"
    destination = "/var/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /var/tmp/scripts/start_consul.sh",
      "sudo bash /var/tmp/scripts/consul-template.sh",
      "sudo bash /var/tmp/scripts/conf-dnsmasq.sh",
      "sudo bash /var/tmp/scripts/check_nginx.sh",
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
