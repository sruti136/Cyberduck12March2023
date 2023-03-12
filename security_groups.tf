
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "complete-mysql-sg"
  description = "Complete MySQL example security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = "10.0.0.0/22"
    },
  ]

  tags = {
    Name       = "mysql_rds_security_group"
  }
}

####-----
resource "aws_security_group" "asg" {
  name   = "asg-sg"
  vpc_id = module.vpc.vpc_id

  tags = {
    Name        = "asg-sg"

  }
}

# =====| EGRESS RULES |================================================

resource "aws_security_group_rule" "rds" {
  security_group_id = aws_security_group.asg.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/22"]
  from_port         = 3306
  to_port           = 3306
}

resource "aws_security_group_rule" "ssm_https" {
  security_group_id = aws_security_group.asg.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
}

# =====| INGRESS RULES |===============================================

resource "aws_security_group_rule" "ingress_lb" {
  security_group_id = aws_security_group.asg.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["10.0.4.0/22"]
  from_port         = 80
  to_port           = 80
}


resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.asg.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["10.0.4.0/22"]
  from_port         = 22
  to_port           = 22
}

