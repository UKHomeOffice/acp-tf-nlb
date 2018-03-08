Module usage:

     module "nlb" {
       source         = "git::https://github.com/UKHomeOffice/acp-tf-nlb?ref=master"

       name            = "my-service"
       environment     = "dev"            # by default both Name and Env is added to the tags
       dns_zone        = "example.com"
       tags            = {
         Role = "some_tag"
       }
       # A series of tags applied to filter out the source subnets, by default Env and Role = elb-subnet is used
       subnet_tags {
         Role = "some_tag"
       }
       ingress = [
         {
           port = "80"
           cidr = "0.0.0.0/0"
         },
         {
           port = "443"
           cidr = "0.0.0.0/0"
         },
       ]
       egress = [
         {
           port = "30200"
           cidr = "0.0.0.0/0"
         },
         {
           port = "30201"
           cidr = "0.0.0.0/0"
         },
       ]
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
| dns_name | An optional hostname to add to the hosting zone, otherwise defaults to var.name | `` | no |
| dns_type | The dns record type to use when adding the dns entry | `CNAME` | no |
| dns_zone | The AWS route53 domain name hosting the dns entry, i.e. example.com | - | yes |
| egress | A map containing the port and cidr which are permitted | - | yes |
| elb_role_tag | The role tag applied to the subnets used for ELB, i.e. Role = elb-subnet | `elb-subnets` | no |
| environment | An envionment name for the ELB, i.e. prod, dev, ci etc and used to search for assets | - | yes |
| idle_timeout | The timeout applie to idle ELB connections | `120` | no |
| ingress | A containing the port and cidr which are permitted access to the NLB | - | yes |
| internal | Indicates if the ELB should be an internal load balancer, defaults to true | `true` | no |
| listeners | An array of listeners to setup for the NLB | - | yes |
| name | A descriptive name for this ELB | - | yes |
| security_groups | An optional list of security groups added to the created ELB | `<list>` | no |
| subnet_tags | A map of tags used to filter the subnets you want the ELB attached | `<map>` | no |
| tags | A map of tags which will be added to the ELB cloud tags, by default Name, Env and KubernetesCluster is added | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb_dns_name |  |
| alb_id |  |
| dns |  |
| security_group_id |  |

