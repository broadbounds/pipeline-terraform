provider "aws" {
   region  = "us-east-2"
   access_key = var.access_key
   secret_key = var.secret_key
 }

resource "aws_vpc" "vpc" {
   cidr_block = "192.168.0.0/16"
   instance_tenancy = "default"
   tags = {
      Name = "VPC"
   }
   enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnet" {
   depends_on = [
      aws_vpc.vpc,
   ]
   vpc_id = aws_vpc.vpc.id
   cidr_block = "192.168.0.0/24"
   availability_zone_id = "us-east-2a"
   tags = [
      Name = "public-subnet"
   ]
   map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet" {
   depends_on = [
      aws_vpc.vpc,
   ]
   vpc_id = aws_vpc.vpc.id
   cidr_block = "192.168.1.0/24"
   availability_zone_id = "us-east-2b"
   tags = [
      Name = "private-subnet"
   ]
}

resource "aws_internet_gateway" "internet_gateway" {
   depends_on = [
      aws_vpc.vpc,
   ]
   vpc_id = aws_vpc.vpc.id
   tags = [
      Name = "internet-gateway"
   ]
}

resource "aws_route_table" "IG_route_table" {
   depends_on = [
      aws_vpc.vpc,
      aws_internet_gateway.internet_gateway,
   ]
   vpc_id = aws_vpc.vpc.id
   route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.internet_gateway.id
   }
   tags = [
      Name = "IG-route-table"
   ]
}

resource "aws_route_table_association" "associate_routetable_to_public_subnet" {
   depends_on = [
      aws_subnet.public_subnet,
      aws_route_table.IG_route_table,
   ]
   subnet_id = aws_subnet.public_subnet.id
   route_table_id = aws_route_table.IG_route_table.id
}

resource "aws_eip" "elastic_ip" {
   vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
   depends_on = [
      aws_subnet.public_subnet,
      aws_eip.elastic_ip,
   ]
   allocation_id = aws_eip.elastic_ip.id
   subnet_id = aws_subnet.public_subnet.id
   tags = [
      Name = "nat-gateway"
   ]
}

resource "aws_route_table" "NAT_route_table" {
   depends_on = [
      aws_vpc.vpc,
      aws_nat_gateway.nat_gateway,
   ]
   vpc_id = aws_vpc.vpc.id
   route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.nat_gateway.id
   }
   tags = [
      Name = "NAT-route-table"
   ]
}

resource "aws_route_table_association" "associate_routetable_to_private_subnet" {
   depends_on = [
      aws_subnet.private_subnet,
      aws_route_table.NAT_route_table,
   ]
   subnet_id = aws_subnet.private_subnet.id
   route_table_id = aws_route_table.NAT_route_table.id
}

resource "aws_security_group" "sg_bastion_host" {
   depends_on = [
      aws_vpc.vpc,
   ]
   name = "sg bastion host"
   description = "bastion host security group"
   vpc_id = aws_vpc.vpc.id
   ingress {
      description = "allow ssh"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }
   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_instance" "bastion_host" {
   depends_on = [
      aws_security_group.sg_bastion_host,
   ]
   ami = "ami-077e31c4939f6a2f3"
   instance_type = "t2.micro"
   key_name = var.key.name
   vpc_security_group_ids = [aws_security_group.sg_bastion_host.id]
   subnet_id = aws_subnet.public_subnet.id
   tags = {
      Name = "bastion host"
   }
}
