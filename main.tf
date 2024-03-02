#Create security group
resource "aws_security_group" "sg" {
  name        = replace(local.name, "rtype", "sg")
  description = "Allow inbound traffic"
  tags        = local.common_tags
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  count             = length(var.ports) # this length it is giving list, map, string
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = element(var.cidr_blocks, count.index)
  from_port         = element(var.ports, count.index)
  ip_protocol       = "tcp"
  to_port           = element(var.ports, count.index)
}

#Create Launch template
resource "aws_launch_template" "main-launch-template" {
  name_prefix   = replace(local.name, "rtype", "launch_template")
  tags          = local.common_tags
  image_id      = var.image_ig
  instance_type = "t2.micro"
  key_name      = var.key_pair

  network_interfaces {
    device_index = 0
    subnet_id    = var.subnet_id
  }
}

#Create AutoScaling
resource "aws_autoscaling_group" "main-asg" {
  name = replace(local.name, "rtype", "asg")

  launch_template {
    id      = aws_launch_template.main-launch-template.id
    version = "$Latest"
  }
  min_size                  = var.min_asg
  max_size                  = var.max_asg
  desired_capacity          = var.desires_asg
  health_check_type         = "EC2"
  health_check_grace_period = 300
  vpc_zone_identifier       = var.list_subnets # Put your subnet ID here

  dynamic "tag" {
    for_each = data.aws_default_tags.tags.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}



#Request ACM
resource "aws_acm_certificate" "main-acm" {
  domain_name       = var.domain
  tags              = local.common_tags
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "main-cname" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.main-acm.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.main-acm.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.main-acm.domain_validation_options)[0].resource_record_type
  zone_id         = var.zone_id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "main-cert-validate" {
  certificate_arn         = aws_acm_certificate.main-acm.arn
  validation_record_fqdns = [aws_route53_record.main-cname.fqdn]
}

resource "null_resource" "wait_acm_validation" {
  provisioner "local-exec" {
    command = "sleep 60" # Adjust the wait time according to your needs
  }

  depends_on = [aws_route53_record.main-cname]
}

# Create target group
resource "aws_lb_target_group" "main-tg" {
  name     = replace(local.name, "rtype", "tg")
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/index.html"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
# Create security group for the load balancer
resource "aws_security_group" "main-sg-lb" {
  name        = replace(local.name, "rtype", "sg-lb")
  description = "Security group for the example load balancer"
  tags        = local.common_tags

  vpc_id = var.vpc_id
}
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4-lb" {
  count             = length(var.ports) # this length it is giving list, map, string
  security_group_id = aws_security_group.main-sg-lb.id
  cidr_ipv4         = element(var.cidr_blocks, count.index)
  from_port         = element(var.ports, count.index)
  ip_protocol       = "tcp"
  to_port           = element(var.ports, count.index)
}

# Create Application Load Balancer
resource "aws_lb" "main-alb" {
  name               = replace(local.name, "rtype", "alb")
  tags               = local.common_tags
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main-sg-lb.id]
  subnets            = var.list_subnets # Put your subnet IDs here

  enable_deletion_protection = false

}


resource "aws_lb_listener" "main-list-http" {
  load_balancer_arn = aws_lb.main-alb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main-tg.arn
  }
}

resource "aws_lb_listener" "main-list-https" {
  load_balancer_arn = aws_lb.main-alb.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.main-acm.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main-tg.arn
  }
}

resource "aws_lb_listener_certificate" "client-app_tls_certificate" {
  listener_arn    = aws_lb_listener.main-list-https.arn
  certificate_arn = aws_acm_certificate.main-acm.arn
}

# Create Route 53 DNS records for the main domain
resource "aws_route53_record" "main-arecord" {
  zone_id = var.zone_id # Put your hosted zone ID here
  name    = var.domain
  type    = "A"
  alias {
    name                   = aws_lb.main-alb.dns_name
    zone_id                = var.zone_id # Put your ALB zone ID here
    evaluate_target_health = true
  }
}
