#output "dns" {
#  description = "The FQDN of the newly created ELB"
#  value       = "${var.dns_name}.${var.dns_zone}"
#}
#
#output "alb_id" {
#  description = "The ID for the ELB which has been created"
#  value       = "${aws_lb.balancer.id}"
#}
#
#output "alb_dns_name" {
#  description = "The name given to the ELB just created"
#  value       = "${aws_lb.balancer.dns_name}"
#}
#
#output "security_group_id" {
#  description = "The ID for the security used to protected the NLB"
#  value       = "${aws_security_group.sg.id}"
#}

