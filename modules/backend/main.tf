variable "namespace" {}
variable "vpc" {}
variable "security_group_id" {}

resource "aws_security_group" "allow_ssh_pub" {
  name        = "${var.namespace}-allow_ssh"
  description = "inbound de ssh tipo publico"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "SSH desde todo internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.namespace}-ssh"
  }
}
// busco en aws por filtro la versión disponible (aws educate solo deja una)
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}
resource "aws_instance" "instance" {
  ami = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type = "t2.micro"
  subnet_id = var.vpc.public_subnets[0]
  vpc_security_group_ids = [
    var.security_group_id]
  tags = {
    "Name" = "${var.namespace}-EC2-FRONTEND"
  }
  # Copies the ssh key file to home dir
  provisioner "file" {
    source = "./${var.key_name}.pem"
    destination = "/home/ec2-user/${var.key_name}.pem"
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("${var.key_name}.pem")
      host = self.public_ip
    }
  }
  //chmod key 400 on EC2 instance
  provisioner "remote-exec" {
    inline = [
      "chmod 400 ~/${var.key_name}.pem"]
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("${var.key_name}.pem")
      host = self.public_ip
    }
  }
}

