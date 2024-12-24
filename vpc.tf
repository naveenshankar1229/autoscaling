resource "aws_vpc" "dev" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "${var.vpc_name}"
  }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev.id
  tags = {
    "Name" = "${var.vpc_name}-igw"
  }

}

resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = element(var.cidr_block_public, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public${count.index + 1}"
  }

}
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.dev.id
  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "${var.vpc_name}-rt"
  }
}

resource "aws_route_table_association" "associate" {
  count          = 3
  route_table_id = aws_route_table.rt.id
  subnet_id      = element(aws_subnet.public.*.id, count.index)

}

resource "aws_security_group" "sg" {
  vpc_id      = aws_vpc.dev.id
  name        = "dev-group"
  description = "allow all rules"
  tags = {
    Name = "${var.vpc_name}-sg"

  }
  ingress {
    to_port     = 0
    from_port   = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    to_port     = 0
    from_port   = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "server" {
  count                       = 2
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = element(aws_subnet.public.*.id, count.index)
  private_ip                  = element(var.private_ip, count.index)
  associate_public_ip_address = true
  user_data                   = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install openjdk-17-jre-headless
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
    EOF
  tags = {
    Name = "${var.vpc_name}-server${count.index + 1}"
  }

}