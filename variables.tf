variable "name" {
  description = "A descriptive name for this ELB"
}

variable "environment" {
  description = "An envionment name for the ELB, i.e. prod, dev, ci etc and used to search for assets"
}

variable "dns_zone" {
  description = "The AWS route53 domain name hosting the dns entry, i.e. example.com"
}

variable "dns_name" {
  description = "An optional hostname to add to the hosting zone, otherwise defaults to var.name"
  default     = ""
}

variable "dns_type" {
  description = "The dns record type to use when adding the dns entry"
  default     = "A"
}

variable "elb_role_tag" {
  description = "The role tag applied to the subnets used for ELB, i.e. Role = elb-subnet"
  default     = "elb-subnets"
}

variable "subnet_tags" {
  description = "A map of tags used to filter the subnets you want the ELB attached"
  default     = {}
}

variable "listeners" {
  description = "An array of listeners to setup for the NLB"
  type        = "list"
}

variable "tags" {
  description = "A map of tags which will be added to the ELB cloud tags, by default Name, Env and KubernetesCluster is added"
  default     = {}
}

variable "internal" {
  description = "Indicates if the ELB should be an internal load balancer, defaults to true"
  default     = true
}

variable "idle_timeout" {
  description = "The timeout applie to idle ELB connections"
  default     = "120"
}

variable "deregistration_delay" {
  description = "The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused"
  default     = "300"
}

variable "health_check_interval" {
  description = "The interval between performing a health check"
  default     = "30"
}

variable "healthy_threshold" {
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy"
  default     = "3"
}

variable "unhealthy_threshold" {
  description = "The number of consecutive health check failures required before considering the target unhealthy"
  default     = "3"
}

variable "vpc_id" {
  description = "The VPC id you are building the network load balancer in"
}
