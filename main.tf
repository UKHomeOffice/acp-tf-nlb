resource "aws_security_group" "balancer" {
  count       = var.disable_security_groups ? 0 : 1
  name        = "nlb-${var.name}-sg-rds"
  description = "The security group used to manage access to NLB: ${var.name}"
  vpc_id      = var.vpc_id

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

resource "aws_security_group_rule" "ingress" {
  for_each          = {
    for key, value in var.ports : key => value
    if var.disable_security_groups == false
  }

  type              = "ingress"
  from_port         = each.key
  to_port           = each.key
  protocol          = "tcp"
  cidr_blocks       = var.security_group_ingress_cidr
  security_group_id = aws_security_group.balancer[0].id
}

resource "aws_security_group_rule" "egress" {
  count             = var.disable_security_groups ? 0 : 1
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.balancer[0].id
}

resource "aws_lb_target_group" "target_groups" {
  for_each = var.ports

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

resource "aws_autoscaling_attachment" "asg_attachment" {
  /*
  Terraform maps are notoriously difficult to follow, but unfortunately this was the only way to have a coherent input to the module.
  Assumptions:
  1. We need to use a map so that when the list is modified only the ones changed get touched (i.e what would happenw with a list is that if you remove an item, everything after it would get shifted left and recreated).
  2. There is one attachment per ASG per targetgroup

  What this does is returns a map of type map(object( asg_name = string, target_group_index = string))
  With the Key of the map being the unique key of the attachment e.g
  {
    "$NLBPORT-$NODEPORT-$ASGNAME" = {
        asg_name           = $ASGNAME
        target_group_index = $NLBPORT
    }
  }
  The map key "$NLBPORT-$NODEPORT-$ASGNAME" is needed as each attachment needs to be unique
    asg_name, the name of the ASG to attach
    target_group_index, the index of the target group to attach to
  */
  for_each = merge(flatten(
    [for nlb_port, target in var.ports : {
      for asg_name in target["target_groups"] : "${nlb_port}-${target["target_port"]}-${asg_name}" => {
        asg_name           = asg_name
        target_group_index = nlb_port
      }
    }]
  )...)

  autoscaling_group_name = each.value["asg_name"]
  alb_target_group_arn   = aws_lb_target_group.target_groups[each.value.target_group_index].arn
}

resource "aws_lb_listener" "listeners" {
  for_each = var.ports

  load_balancer_arn = aws_lb.balancer.arn
  port              = each.key
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.target_groups[each.key].arn
    type             = "forward"
  }
}

resource "aws_lb" "balancer" {
  name = "${var.environment}-${var.name}-nlb"

  enable_cross_zone_load_balancing = "true"
  internal                         = length(var.internal_nlb_subnet_mappings) > 0 ? true : var.internal
  load_balancer_type               = "network"
  subnets                          = length(var.internal_nlb_subnet_mappings) > 0 ? null : var.subnet_ids

  dynamic "subnet_mapping" {
    for_each = var.internal_nlb_subnet_mappings
    content {
      subnet_id            = subnet_mapping.value.subnet_id
      private_ipv4_address = subnet_mapping.value.private_ipv4_address
    }
  }

  security_groups                  = var.disable_security_groups ? null : [aws_security_group.balancer[0].id] # Disable for backwards compatability with version 2 of this module

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
