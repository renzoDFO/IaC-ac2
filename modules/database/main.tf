// SG
resource "aws_security_group" "database" {
  name = "${var.namespace}-database"
  vpc_id = var.vpc.vpc_id
  ingress {
    description = "SSH desde mi backend"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "10.0.0.0/16"]
  }
  ingress {
    description = "27017 desde mi backend"
    from_port = 27017
    to_port = 27017
    protocol = "tcp"
    cidr_blocks = [
      "10.0.0.0/16"]
  }
  egress {
    description = "Egress total"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Name = "${var.namespace}-database-sg"
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
  associate_public_ip_address = false
  instance_type = "t2.micro"
  key_name = var.private_key_name
  subnet_id = var.vpc.private_subnets[0]
  vpc_security_group_ids = [
    aws_security_group.database.id]
  tags = {
    "Name" = "${var.namespace}-EC2-DATABASE"
  }
  # Init Script
  provisioner "file" {
    source = "./init.script"
    destination = "/home/ec2-user/init.script"
    connection {
      timeout = "15m"
      type = "ssh"
      user = "ec2-user"
      private_key = file("${var.private_key_name}.pem")
      host = self.private_ip
    }
  }
  // Le añado permisos & ejecuto el init script
  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/init.script",
      "/bin/sh /home/ec2-user/init.script > /init.log"]
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