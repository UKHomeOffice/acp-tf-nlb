data "aws_route53_zone" "selected" {
  name = "${var.dns_zone}."
}
