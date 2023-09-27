
moved {
  from = aws_instance.server
  to   = module.alb.aws_instance.main
}

moved {
  from = aws_lb_target_group_attachment.server
  to   = module.alb.aws_lb_target_group_attachment.main
}

moved {
  from = aws_iam_role.server
  to   = module.alb.aws_iam_role.main
}

moved {
  from = aws_iam_instance_profile.server
  to   = module.alb.aws_iam_instance_profile.main
}

moved {
  from = aws_lb.main
  to   = module.alb.aws_lb.main
}

moved {
  from = aws_lb_target_group.main
  to   = module.alb.aws_lb_target_group.main
}

moved {
  from = aws_lb_listener.main
  to   = module.alb.aws_lb_listener.main
}

moved {
  from = aws_security_group.main
  to   = module.alb.aws_security_group.main
}

module "alb" {
  source          = "./alb"
  name            = var.name
  authorized_keys = var.authorized_keys
  allow_ssh_ips   = var.allow_ssh_ips
}


module "lambda" {
  source = "./lambda"
  name   = var.name
}
