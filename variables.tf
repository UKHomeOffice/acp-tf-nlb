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

variable "subnet_ids" {
  description = "A list of subnet id's to be used for the NLB"
}

variable "ports" {
  description = "A map of ports and autoscaling groups to make listeners/target groups/ attachments from"
  type = map(object({
    target_port   = string
    target_groups = list(string)
  }))
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

variable "preserve_client_ip" {
  description = "Whether to preserve the client (source) IP - false will regard all traffic as originating from the eni, for example"
  default     = true
}

variable "security_group_ingress_cidr" {
  description = "CIDR ranges to allow access to this NLB"
  type        = list(string)
}

variable "disable_security_groups" {
  description = "Disable SecurityGroup creation, this is for backwards compatability as SG's can't be added after creation"
  default     = false
}

variable "use_nlb_internal_subnet_mappings" {
  description = "Boolean flag to conditionally use subnet mappings to specify private IP addresses for internal facing NLB"
  default     = false
}

variable "subnet_mappings" {
  type = map(object({
    subnet_id            = string,
    private_ipv4_address = string
  }))
  default = {}
}
