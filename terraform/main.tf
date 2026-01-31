provider "aws"{
    region = "us-east-1"
}

resource "aws_security_group" "web_sg" {
    name = "sg_web_nginx"
    description = "Permite acesso HTTP e SSH"

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

data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
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

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install nginx -y
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Deploy Automatizado com Terraform e Ansible</h1>" > /var/www/html/index.html
              EOF

  provisioner "local-exec" {
    command = "export ANSIBLE_HOST_KEY_CHECKING=False && ansible-playbook -i '${self.public_ip},' ../ansible/playbook.yml -u ubuntu --private-key ~/.ssh/id_ed25519"
  }

  tags = {
    Name = "WebServer-Terraform"
  }
}

output "public_ip" {
  value = aws_instance.web_server.public_ip
}