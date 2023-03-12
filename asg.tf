module "alb_http_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "~> 4.0"

  name        = "${local.name}-alb-http"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for ${local.name}"

  ingress_cidr_blocks = ["0.0.0.0/0"]  // to allow outside world hit LB a-record.

  tags = {
    Name       = "mysql_alb_http_sg"
  }
}

module "alb" {  // This is simply saying I am in 
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = local.name

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.alb_http_sg.security_group_id]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name             = local.name
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    },
  ]

  tags = {
    Name       = "cyber-alb"
  }
}

resource "aws_iam_instance_profile" "asg_prof" {
  name = "asg-prof"
  role = aws_iam_role.asg_role.name
}

resource "aws_iam_role" "asg_role" {
  name               = "asg-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.asg_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_launch_template" "asg" {
  image_id               = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  name_prefix            = "asg"
  user_data              = base64encode(local.user_data)
  update_default_version = true
  
  iam_instance_profile {
    name = aws_iam_instance_profile.asg_prof.name
  }

  network_interfaces {
    security_groups = [aws_security_group.asg.id]
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      encrypted   = true
      volume_size = 50
      volume_type = "gp3"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  default_cooldown          = 120
  health_check_grace_period = 300
  max_size                  = 1
  min_size                  = var.min_size
  desired_capacity = 1
  name_prefix               = "asg-"
  termination_policies      = ["OldestInstance"]
  target_group_arns = module.alb.target_group_arns

  vpc_zone_identifier = module.vpc.database_subnets

  launch_template {
    id      = aws_launch_template.asg.id
    version = "$Latest"
  }

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMinSize",
    "GroupMaxSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "asg"
  }
}

resource "aws_autoscaling_policy" "asg" {
  name                      = "asg-policy"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.asg.name
  estimated_instance_warmup = 200

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 40.0
  }
}

