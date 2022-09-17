provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region     = "us-west-1"
}

resource "aws_instance" "Reverse-Proxy" {
  instance_type          = "t2.micro"
  ami                    = "ami-085284d24fe829cd0"
  key_name               = "MRIS"
  tags = {
    Name = "OPSYSTEM"
  }
  vpc_security_group_ids = [aws_security_group.WebSG.id]
  user_data              = filebase64("${path.module}/scripts/docker.sh")
}

resource "aws_security_group" "WebSG" {
  name = "sg_reglas_firewall"
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
  value = "${join(",", aws_instance.Reverse-Proxy.*.public_ip)}"
}
