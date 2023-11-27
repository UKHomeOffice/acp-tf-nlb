## Changelogs

v2.1.0 - Added mandatory ingress cidr range variable for the security group  
v2.0.0 - Breaking changes, renaming var.listeners to var.ports and turns it into an map(object) which uses the ports as indexes so doesn't cause the Terraform index shift recreation issue and also accepts multiple target groups  
v1.0.5 - Adds support for the boolean argument 'preserve_client_ip'  


## Usage
     module "nlb" {
       source         = "git::https://github.com/UKHomeOffice/acp-tf-nlb?ref=master"

       name            = "my-service"
       environment     = "dev"            # by default both Name and Env is added to the tags
       dns\_zone        = "example.com"
       vpc\_id          = "vpc-32323232"
       tags            = {
         Role = "some\_tag"
       }
       # A series of tags applied to filter out the source subnets, by default Env and Role = elb-subnet is used
       subnet\_tags {
         Role = "some\_tag"
       }

       ports = {
         "80" = {
           target_port   = "8080"
           target_groups = ["compute-az1", "compute-az2"]
         },
         "443" = {
           target_port   = "8443"
           target_groups = ["compute-az1", "compute-az2]
         }
       }
     }

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.71.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_attachment.asg_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_attachment) | resource |
| [aws_lb.balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.listeners](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.target_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_subnet_ids.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_blocks"></a> [cidr\_blocks](#input\_cidr\_blocks) | CIDR ranges to allow access to this NLB | `list(string)` | n/a | yes |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused | `string` | `"300"` | no |
| <a name="input_dns_name"></a> [dns\_name](#input\_dns\_name) | An optional hostname to add to the hosting zone, otherwise defaults to var.name | `string` | `""` | no |
| <a name="input_dns_type"></a> [dns\_type](#input\_dns\_type) | The dns record type to use when adding the dns entry | `string` | `"A"` | no |
| <a name="input_dns_zone"></a> [dns\_zone](#input\_dns\_zone) | The AWS route53 domain name hosting the dns entry, i.e. example.com | `any` | n/a | yes |
| <a name="input_elb_role_tag"></a> [elb\_role\_tag](#input\_elb\_role\_tag) | The role tag applied to the subnets used for ELB, i.e. Role = elb-subnet | `string` | `"elb-subnets"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | An envionment name for the ELB, i.e. prod, dev, ci etc and used to search for assets | `any` | n/a | yes |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | The interval between performing a health check | `string` | `"30"` | no |
| <a name="input_healthy_threshold"></a> [healthy\_threshold](#input\_healthy\_threshold) | The number of consecutive health checks successes required before considering an unhealthy target healthy | `string` | `"3"` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | The timeout applie to idle ELB connections | `string` | `"120"` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | Indicates if the ELB should be an internal load balancer, defaults to true | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | A descriptive name for this ELB | `any` | n/a | yes |
| <a name="input_ports"></a> [ports](#input\_ports) | A map of ports and autoscaling groups to make listeners/target groups/ attachments from | <pre>map(object({<br>    target_port   = string<br>    target_groups = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_preserve_client_ip"></a> [preserve\_client\_ip](#input\_preserve\_client\_ip) | Whether to preserve the client (source) IP - false will regard all traffic as originating from the eni, for example | `bool` | `true` | no |
| <a name="input_subnet_tags"></a> [subnet\_tags](#input\_subnet\_tags) | A map of tags used to filter the subnets you want the ELB attached | `map` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags which will be added to the ELB cloud tags, by default Name, Env and KubernetesCluster is added | `map` | `{}` | no |
| <a name="input_unhealthy_threshold"></a> [unhealthy\_threshold](#input\_unhealthy\_threshold) | The number of consecutive health check failures required before considering the target unhealthy | `string` | `"3"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC id you are building the network load balancer in | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns"></a> [dns](#output\_dns) | The FQDN of the newly created ELB |
| <a name="output_nlb_arn"></a> [nlb\_arn](#output\_nlb\_arn) | The AWS ARN of the NLB which has been created |
| <a name="output_nlb_dns_name"></a> [nlb\_dns\_name](#output\_nlb\_dns\_name) | The name given to the ELB just created |
| <a name="output_nlb_id"></a> [nlb\_id](#output\_nlb\_id) | The ID for the ELB which has been created |
| <a name="output_nlb_name"></a> [nlb\_name](#output\_nlb\_name) | The name of the network load balancer we are creating |
<!-- END_TF_DOCS -->
