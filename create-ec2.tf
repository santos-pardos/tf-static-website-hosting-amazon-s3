provider "aws" {
  region = "us-east-1"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "ride-share-key"
  public_key = tls_private_key.private_key.public_key_openssh
}

resource "aws_security_group" "security_group" {
  name        = "ride-sharing-sg"
  description = "Allow SSH inbound traffic"

  ingress {
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
}

resource "aws_instance" "ride_share_instance" {
  ami           = "ami-14c5486b"
  instance_type = "t2.micro"
  key_name = aws_key_pair.generated_key.key_name

  tags = {
    Name = "ride-share"
  }

  vpc_security_group_ids = [aws_security_group.security_group.id]
}

output "private_key" {
  value     = tls_private_key.private_key.private_key_pem
  sensitive = true
}