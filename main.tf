provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region     = "us-west-1"
}

resource "aws_instance" "Docker-swarm" {
  instance_type          = "t2.micro"
  count                  = 3
  ami                    = "ami-085284d24fe829cd0"
  key_name               = "MRIS"
  tags = {
    "Name" = "OPSYSTEM-${count.index}"
  }
  vpc_security_group_ids = [aws_security_group.DockerWebSG.id]
  user_data              = filebase64("${path.module}/scripts/docker.sh")
}

resource "aws_security_group" "DockerWebSG" {
  name = "sg_reglas_firewall_docker_swarm"
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG HTTPS"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["187.189.168.51/32"]
    description = "SG SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG All trafic Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  } 
}

output "public_ip" {
  value = "${join(",", aws_instance.Docker-swarm.*.public_ip)}"
}
