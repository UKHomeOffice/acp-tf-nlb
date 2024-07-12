output "dns" {
  description = "The FQDN of the newly created ELB"
  value       = "${var.dns_name}.${var.dns_zone}"
}

output "nlb_id" {
  description = "The ID for the ELB which has been created"
  value       = var.use_nlb_internal_subnet_mappings ? aws_lb.balancer_int_with_subnet_mappings[0].id : aws_lb.balancer[0].id
}

output "nlb_arn" {
  description = "The AWS ARN of the NLB which has been created"
  value       = var.use_nlb_internal_subnet_mappings ? aws_lb.balancer_int_with_subnet_mappings[0].arn : aws_lb.balancer[0].arn
}

output "nlb_name" {
  description = "The name of the network load balancer we are creating"
  value       = var.name
}

output "nlb_dns_name" {
  description = "The name given to the ELB just created"
  value       = var.use_nlb_internal_subnet_mappings ? aws_lb.balancer_int_with_subnet_mappings[0].dns_name : aws_lb.balancer[0].dns_name
}

