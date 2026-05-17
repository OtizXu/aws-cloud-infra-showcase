resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = { Name = "${var.name_prefix}-vpc-${var.environment}" }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets_cidrs)
  vpc_id = aws_vpc.this.id
  cidr_block = var.private_subnets_cidrs[count.index]
  availability_zone = element(var.azs, count.index)
  tags = { Name = "${var.name_prefix}-private-${count.index}-${var.environment}" }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidrs)
  vpc_id = aws_vpc.this.id
  cidr_block = var.public_subnets_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone = element(var.azs, count.index)
  tags = { Name = "${var.name_prefix}-public-${count.index}-${var.environment}" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.name_prefix}-igw-${var.environment}" }
}

output "vpc_id" { value = aws_vpc.this.id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
