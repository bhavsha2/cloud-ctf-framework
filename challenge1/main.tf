
locals {
  ports_in = [
    0
  ]
  ports_out = [
    0
  ]
}

resource "aws_vpc" "ctf_challenge1_vpc" {
    cidr_block ="10.0.0.0/16"
    #instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    tags = {
      Name = "ctf_challenge1_vpc"
    }
  
}




resource "aws_default_network_acl" "default" {
    default_network_acl_id = aws_vpc.ctf_challenge1_vpc.default_network_acl_id
    ingress{
        protocol = -1
        rule_no = 100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0

    }
    ingress{
        cidr_block = "20.20.20.20/32"
        rule_no = 110
        action="allow"
        from_port = 22
        to_port = 22
        protocol="tcp"
    }
    ingress{
        cidr_block = "40.40.40.40/32"
        rule_no = 120
        action="allow"
        from_port = 443
        to_port = 443
        protocol="tcp"
            
    }
    ingress{
        #cidr_block = "106.203.219.180/32"
        cidr_block = "64.102.249.9/32" # public ip of the vm from where we would test 
        #cidr_block = "72.163.220.7/32" #currently setting this local ip which is my machine as testing locally
        rule_no = 130
        action = "allow"
        protocol = "tcp"
        from_port = 80
        to_port = 80
    }
    

    egress{
        protocol = -1
        rule_no = 100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
        
    }
      tags = {
      Name = "challenge1_nacl"
    }
      
}
#Subnets This is a public subnet 
resource "aws_subnet" "my-public" {
    vpc_id = aws_vpc.ctf_challenge1_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = lookup(var.availability_zone , var.AWS_REGION)
    tags = {
        Name = "ctf-public-1"
    }

  
}
# Subnet This is a private subnet
resource "aws_subnet" "my-private" {
    vpc_id = aws_vpc.ctf_challenge1_vpc.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = lookup(var.availability_zone , var.AWS_REGION)
    tags = {
      Name = "ctf-private-1"
    }

  
}

#Internet GW
resource "aws_internet_gateway" "main-igw" {
    vpc_id = aws_vpc.ctf_challenge1_vpc.id
    tags = {
        Name = "CTFInternetGW"
    }
  
}

#Route table This basically calls the Internet gateway 
resource "aws_route_table" "main-public" {
    vpc_id = aws_vpc.ctf_challenge1_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main-igw.id

    }
    tags = {
        Name = "ctf-public-internet"
    }
}

#Route association This basically associates the rouute to internet gateway i...e setting default route for the internet 
resource "aws_route_table_association" "main-public-1-a" {
    subnet_id = aws_subnet.my-public.id
    route_table_id = aws_route_table.main-public.id
  
}



resource "aws_security_group" "vpc_security_group"{
    name = "ctf_security_group"
    vpc_id = aws_vpc.ctf_challenge1_vpc.id
    dynamic "ingress"{
        for_each = toset(local.ports_in)
        content{

        description = "inbound to Ec2"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        }


    }

    dynamic "egress"{
        for_each = toset(local.ports_out)
        content{

        
        description = "inbound to Ec2"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        }

    }
    tags = {
        Name = "challenge1-security-group"
    }

}


output "vpc_id" {
    description = "vpc id"
    value = aws_vpc.ctf_challenge1_vpc.id
}

output "public_ip" {
    value = aws_instance.chall1http.public_ip
}