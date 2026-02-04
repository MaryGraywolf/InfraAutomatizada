terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws"{
    region = "us-east-1"
}

data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
      name = "Rede-Loucuras"
    }
}

resource "aws_internet_gateway" "g_main" {
  vpc_id = aws_vpc.main.id
  tags = {
    name = "gw-rede-loucuras"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet-Publica"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.g_main.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "webserver" {
    name = "sg_web_nginx"
    description = "Permite acesso HTTP e SSH"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 80
        to_port     = 80
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

resource "aws_key_pair" "key_project" {
  key_name = "key_project_pos"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name = aws_key_pair.key_project.key_name
  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.webserver.id]

  provisioner "remote-exec" {
    inline = ["echo 'Wait for SSH connection'"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
      host        = self.public_ip
    }
  }

  provisioner "local-exec" {
    command = "export ANSIBLE_HOST_KEY_CHECKING=False && ansible-playbook -i '${self.public_ip},' ../ansible/playbook.yml -u ubuntu --private-key ~/.ssh/id_ed25519"
  }

  tags = {
    Name = "WebServer-Terraform"
  }
}

output "public_ip" {
  description = "IP of the EC2 instance"
  value = aws_instance.web_server.public_ip
}

output "web_url" {
  description = "URL to access the web server"
  value = "http://${aws_instance.web_server.public_ip}"
}