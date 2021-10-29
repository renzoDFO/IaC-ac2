// SG
resource "aws_security_group" "frontend" {
  name = "${var.namespace}-frontend"
  description = "inbound de ssh tipo publico"
  vpc_id = var.vpc.vpc_id
  ingress {
    description = "SSH desde todo internet"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    description = "8080 desde mi frontend"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = []
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Name = "${var.namespace}-ssh"
  }
}

// EC2
// busco en aws por filtro la versión disponible (aws educate solo deja una)
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = [
    "amazon"]
  filter {
    name = "name"
    values = [
      "amzn2-ami-hvm*"]
  }
}
resource "aws_instance" "instance" {
  ami = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type = "t2.micro"
  subnet_id = var.vpc.public_subnets[0]
  vpc_security_group_ids = [
    aws_security_group.frontend.id]
  tags = {
    "Name" = "${var.namespace}-EC2-FRONTEND"
  }
  # Copio la clave SSH a home de ec2user
  provisioner "file" {
    source = "./${var.private_key_name}-key.pem"
    destination = "/home/ec2-user/${var.private_key_name}.pem"
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("${var.private_key_name}.pem")
      host = self.public_ip
    }
  }
  // le reduzco los permisos a solo lectura por el owner
  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/${var.private_key_name}.pem"]
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("${var.private_key_name}.pem")
      host = self.public_ip
    }
  }
}

// Outputs
output "public_ip" {
  value = aws_instance.instance.public_ip
}
output "private_ip" {
  value = aws_instance.instance.private_ip
}
output "security_group_id" {
  value = aws_security_group.frontend.id
}