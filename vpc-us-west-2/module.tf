provider "aws" {
  region                  = var.region
  shared_credentials_file = "/path/to/credentials"
  profile                 = "default"
}

data "aws_availability_zones" "available" {
}

resource "aws_vpc" "main-us-west" {
  cidr_block           = "10.25.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "vpc-${var.region}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.main-us-west.id

  tags = {
    Name = "cdn-${var.region}-igw"
  }
}

# Public subnet creation
resource "aws_subnet" "public" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.main-us-west.id
  cidr_block              = cidrsubnet(aws_vpc.main-us-west.cidr_block, 6, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "cdn-${element(data.aws_availability_zones.available.names, count.index)}-public"
  }
}

resource "aws_route_table" "public" {
  count  = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.main-us-west.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}

resource "aws_route_table_association" "public" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}

# Private Subnet Creation

resource "aws_subnet" "private" {
  count  = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.main-us-west.id
  cidr_block = cidrsubnet(
    aws_vpc.main-us-west.cidr_block,
    6,
    count.index + length(aws_subnet.public),
  )
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "cdn-${element(data.aws_availability_zones.available.names, count.index)}-private"
  }
}

resource "aws_route_table" "private" {
  count  = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.main-us-west.id
}

resource "aws_route_table_association" "private" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_security_group" "default" {
  vpc_id = aws_vpc.main-us-west.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#resource "aws_instance" "public-server" {
#  count                  = "${length(data.aws_availability_zones.available.names) * var.servers_per_az}"
#  instance_type          = "${var.instance_type}"
#  ami                    = "ami-079596bf7a949ddf8"
#  subnet_id              = "${element(aws_subnet.public.*.id, count.index)}"
#  vpc_security_group_ids = ["${aws_security_group.default.id}", "${aws_vpc.main-us-west.default_security_group_id}"]
#
#  tags = {
#    Name = "cdn-server-${element(data.aws_availability_zones.available.names, count.index)}-${count.index}"
#  }
#}
#resource "aws_instance" "private-server" {
#  count                  = "${length(data.aws_availability_zones.available.names) * var.servers_per_az}"
#  instance_type          = "${var.instance_type}"
#  ami                    = "ami-079596bf7a949ddf8"
#  subnet_id              = "${element(aws_subnet.private.*.id, count.index)}"
#  vpc_security_group_ids = ["${aws_security_group.default.id}", "${aws_vpc.main-us-west.default_security_group_id}"]
#
#  tags = {
#    Name = "cdn-server-${element(data.aws_availability_zones.available.names, count.index)}-${count.index}"
#  }
#}
