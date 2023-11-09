data "aws_subnet_ids" "selected" {
  vpc_id = var.vpc_id
  tags   = var.subnet_tags
}

data "aws_route53_zone" "selected" {
  name = "${var.dns_zone}."
}