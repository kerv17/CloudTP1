variable "aws_region" {
  description = "The AWS region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "The AMI ID for the instances"
  default     = "ami-067d1e60475437da2" // ami_id for us-east-1 linux 
  
}

variable "Data_path" {
  description = "Path to the user data script"
  default     = "Data.sh"
}

variable "m4_instance_count" {
  description = "Number of M4 instances"
  default     = 5
}

variable "t2_instance_count" {
  description = "Number of T2 instances"
  default     = 4
}

variable "instance_tags" {
  description = "Common tags for instances"
  type        = map(string)
  default = {
    "Environment" = "Dev"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

variable "access_key" {
  description = "Access key"
  type        = string # Replace with the appropriate data type if it's not a string
}

variable "secret_key" {
  description = "Secret key"
  type        = string # Replace with the appropriate data type if it's not a string
}

variable "token" {
  description = "token"
  type        = string # Replace with the appropriate data type if it's not a string
}

provider "aws" {
  region = var.aws_region
  access_key = "ASIAXW6VCEQFR6EIRH6K"
  secret_key = "QzBk8F4rgxRnd3289GaRc3BN7SaEocEQKMXIro8r"
  token = "FwoGZXIvYXdzEHAaDGSw2CessGzXvffKGCLMATRqHn3cHVPFjQe5ZX+TVhK2O8MbNEaciddguAceC3SxMzp4S4fB0I6dZQXqqaDwuETa6q0BaYNIpxqb/HGT5VOpf7qX5QCGL4ydgDsZwkgc06DdR1dqVeHPDayXwqWiwPaumCIbRYxhPVOD1pzzC5GaV0yqneR68c6rRxMt8klxUAN3cUF5kk1MNbHQKgRbeTpG1UvY+Mlzhf3K49qbSyl/MwCz74FwKQCSraszhbeM35YbLGm+i2BBckUBTtFr2s03GwAWLnxfegkTlyim/PyoBjItdRHrHKr4gTfqXVG7aHYHN9xB/LaiMEFqHrH4WcAtfmmQSa6SH0km8qClY2AP"
}

resource "aws_security_group" "security_gp" {
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "instances_m4" {
  ami                    = var.ami_id
  instance_type          = "m4.large"
  vpc_security_group_ids = [aws_security_group.security_gp.id]
  availability_zone      = "us-east-1c"
  user_data              = file(var.Data_path)
  count                  = var.m4_instance_count

  tags = merge(var.instance_tags, {
    "Name" = "M4"
  })
}

resource "aws_instance" "instances_t2" {
  ami                    = var.ami_id
  instance_type          = "t2.large"
  vpc_security_group_ids = [aws_security_group.security_gp.id]
  availability_zone      = "us-east-1d"
  user_data              = file(var.Data_path)
  count                  = var.t2_instance_count

  tags = merge(var.instance_tags, {
    "Name" = "T2"
  })
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_alb" "load_balancer" {
  name            = "load-balancer"
  security_groups = [aws_security_group.security_gp.id]
  subnets         = data.aws_subnets.all.ids
}

resource "aws_alb_target_group" "M4" {
  name     = "M4-instances"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

resource "aws_alb_target_group" "T2" {
  name     = "T2-instances"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.M4.arn
  }
}

resource "aws_alb_listener_rule" "M4_rule" {
  listener_arn = aws_alb_listener.listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.M4.arn
  }
  condition {
    path_pattern {
      values = ["/cluster1"]
    }
  }
}

resource "aws_alb_listener_rule" "T2_rule" {
  listener_arn = aws_alb_listener.listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.T2.arn
  }
  condition {
    path_pattern {
      values = ["/cluster2"]
    }
  }
}

resource "aws_alb_target_group_attachment" "M4_attachments" {
  count            = var.m4_instance_count
  target_group_arn = aws_alb_target_group.M4.arn
  target_id        = aws_instance.instances_m4[count.index].id
  port             = 80
}

resource "aws_alb_target_group_attachment" "T2_attachments" {
  count            = var.t2_instance_count
  target_group_arn = aws_alb_target_group.T2.arn
  target_id        = aws_instance.instances_t2[count.index].id
  port             = 80
}

output "alb_dns_name" {
  description = "The Application Load Balancer DNS name"
  value       = aws_alb.load_balancer.dns_name
}

output "load_balancer_arn_suffix" {
  description = "The Application Load Balancer ARN"
  value       = aws_alb.load_balancer.arn_suffix
}

output "M4_group_arn_suffix" {
  description = "M4 group arn suffix"
  value       = aws_alb_target_group.M4.arn_suffix
}

output "T2_group_arn_suffix" {
  description = "T2 group arn suffix"
  value       = aws_alb_target_group.T2.arn_suffix
}
