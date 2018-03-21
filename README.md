Module usage:

     module "nlb" {
       source         = "git::https://github.com/UKHomeOffice/acp-tf-nlb?ref=master"

       name            = "my-service"
       environment     = "dev"            # by default both Name and Env is added to the tags
       dns_zone        = "example.com"
       vpc_id          = "vpc-32323232"
       tags            = {
         Role = "some_tag"
       }
       # A series of tags applied to filter out the source subnets, by default Env and Role = elb-subnet is used
       subnet_tags {
         Role = "some_tag"
       }

       listeners = [
         {
           port         = "80"
           target_port  = "30200"
           target_group = "compute"
         },
         {
           port         = "443"
           target_port  = "30201"
           target_group = "compute"
         }
       ]
     }



## Inputs

| Name | Description | Default | Required |
|------|-------------|:-----:|:-----:|
| deregistration_delay | The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused | `300` | no |
| dns_name | An optional hostname to add to the hosting zone, otherwise defaults to var.name | `` | no |
| dns_type | The dns record type to use when adding the dns entry | `A` | no |
| dns_zone | The AWS route53 domain name hosting the dns entry, i.e. example.com | - | yes |
| elb_role_tag | The role tag applied to the subnets used for ELB, i.e. Role = elb-subnet | `elb-subnets` | no |
| environment | An envionment name for the ELB, i.e. prod, dev, ci etc and used to search for assets | - | yes |
| health_check_interval | The interval between performing a health check | `30` | no |
| healthy_threshold | The number of consecutive health checks successes required before considering an unhealthy target healthy | `3` | no |
| idle_timeout | The timeout applie to idle ELB connections | `120` | no |
| internal | Indicates if the ELB should be an internal load balancer, defaults to true | `true` | no |
| listeners | An array of listeners to setup for the NLB | - | yes |
| name | A descriptive name for this ELB | - | yes |
| subnet_tags | A map of tags used to filter the subnets you want the ELB attached | `<map>` | no |
| tags | A map of tags which will be added to the ELB cloud tags, by default Name, Env and KubernetesCluster is added | `<map>` | no |
| unhealthy_threshold | The number of consecutive health check failures required before considering the target unhealthy | `3` | no |
| vpc_id | The VPC id you are building the network load balancer in | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| dns |  |
| nlb_arn |  |
| nlb_dns_name |  |
| nlb_id |  |
| nlb_name |  |

