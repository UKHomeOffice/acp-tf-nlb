/**
 * Module usage:
 *
 *      module "nlb" {
 *        source         = "git::https://github.com/UKHomeOffice/acp-tf-nlb?ref=master"
 *
 *        name            = "my-service"
 *        environment     = "dev"            # by default both Name and Env is added to the tags
 *        dns_zone        = "example.com"
 *        vpc_id          = "vpc-32323232"
 *        tags            = {
 *          Role = "some_tag"
 *        }
 *        # A series of tags applied to filter out the source subnets, by default Env and Role = elb-subnet is used
 *        subnet_tags {
 *          Role = "some_tag"
 *        }
 *
 *        listeners = [
 *          {
 *            port         = "80"
 *            target_port  = "30200"
 *            target_group = "compute"
 *          },
 *          {
 *            port         = "443"
 *            target_port  = "30201"
 *            target_group = "compute"
 *          }
 *        ]
 *      }
 *
 */
terraform {
  required_version = ">= 1.0"
}

# Get a list of ELB subnets
data "aws_subnet_ids" "selected" {
  vpc_id = var.vpc_id
  tags   = var.subnet_tags
}

# Get the host zone id
data "aws_route53_zone" "selected" {
  name = "${var.dns_zone}."
}

## Create a listen and target group for each of the listeners
resource "aws_lb_target_group" "target_groups" {
  for_each = var.listeners

  name                 = "${var.environment}-${var.name}-${each.key}"
  deregistration_delay = var.deregistration_delay
  port                 = each.value["target_port"]
  preserve_client_ip   = var.preserve_client_ip
  protocol             = "TCP"
  vpc_id               = var.vpc_id

  health_check {
    interval            = var.health_check_interval
    port                = each.value["target_port"]
    protocol            = "TCP"
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

  tags = merge(
    var.tags,
    {
      "Name" = format("%s-%s-nlb", var.environment, var.name)
    },
    {
      "Env" = var.environment
    },
    {
      "KubernetesCluster" = var.environment
    },
  )
}

## Attach the target groups to the autoscaling group
resource "aws_autoscaling_attachment" "asg_attachment" {
  for_each = merge(flatten(
    [for nlb_port, target in var.listeners : {
      for asg_name in target["target_groups"] : "${nlb_port}-${target["target_port"]}-${asg_name}" => {
        asg_name           = asg_name
        target_group_index = nlb_port
      }
    }]
  )...)

  autoscaling_group_name = each.value["asg_name"]
  alb_target_group_arn   = aws_lb_target_group.target_groups[each.value.target_group_index].arn
}

## Create the listener for the target group - this is a bit of a crap way of doing things,
## surely it makes more sense to a listener to have a source and destination port and then use a single
## target group? .. but hey
resource "aws_lb_listener" "listeners" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.balancer.arn
  port              = each.key
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.target_groups[each.key].arn
    type             = "forward"
  }
}

## The ALB we are creating
resource "aws_lb" "balancer" {
  name = "${var.environment}-${var.name}-nlb"

  enable_cross_zone_load_balancing = "true"
  internal                         = var.internal
  load_balancer_type               = "network"
  subnets                          = data.aws_subnet_ids.selected.ids

  tags = merge(
    var.tags,
    {
      "Name" = format("%s-%s", var.environment, var.name)
    },
    {
      "Env" = var.environment
    },
    {
      "KubernetesCluster" = var.environment
    },
  )
}

## Create a DNS entry for this NLB
resource "aws_route53_record" "dns" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.dns_name == "" ? var.name : var.dns_name
  type    = var.dns_type

  alias {
    name                   = aws_lb.balancer.dns_name
    zone_id                = aws_lb.balancer.zone_id
    evaluate_target_health = true
  }
}
