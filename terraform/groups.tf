# load balancer security group
resource "aws_security_group" "lb_security_group" {
  name        = "load-balancer-sg"
  description = "Security group for Load Balancer"
  vpc_id      = aws_vpc.main.id # vpc id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
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


# Define the Application Security Group
resource "aws_security_group" "application_sg" {
  name        = "application-sg"
  description = "Security group for application servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "port 20, ssh access/allow for test"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description     = "Application Port"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_security_group.id]
  }

  # not needed
  # ingress {
  #   description = "Allow RDS MySQL traffic"
  #   from_port   = 3306
  #   to_port     = 3306
  #   protocol    = "tcp"
  #   cidr_blocks = [aws_subnet.private[0].cidr_block]
  # }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "application_sg"
  }

  #   not used for the load balancer parts. No direct access allowed
  #  allow it for test only
  # ingress {
  #   description = "port 80"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   description = "port 443"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

}

resource "aws_security_group" "database_sg" {
  name        = "database-sg"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow MySQL traffic from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.application_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database_sg"
  }
}

# aws_security_group.lambda_sg
resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Security group for Lambda function"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [] # No inbound traffic
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# subnet group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id] # must apply on two zones
}


# RDS Parameter Group
resource "aws_db_parameter_group" "csye6225_mysql" {
  name        = "caye6225-mysql-parameter-group"
  family      = "mysql8.0"
  description = "Custom MySQL parameter group"

  parameter {
    name  = "max_connections"
    value = "100"
  }
}

# load balancer  
resource "aws_lb" "app_load_balancer" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "dualstack" # dealstack for both IPv4 and IPv6
  security_groups    = [aws_security_group.lb_security_group.id]
  subnets            = [aws_subnet.public[0].id, aws_subnet.public[1].id, aws_subnet.public[2].id]
}
# , taget group
resource "aws_lb_target_group" "app_target_group" {
  name     = "app-target-group"
  port     = 8080   # app port
  protocol = "HTTP" # inside the system
  vpc_id   = aws_vpc.main.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 15
    interval            = 60
    path                = "/healthz"
    matcher             = "200"
  }
}
# and listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_load_balancer.arn
  # For HTTP
  # port              = 80
  # protocol          = "HTTP"

  # For HTTPS
  port     = 443
  protocol = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}
# ag setting
resource "aws_autoscaling_group" "application_asg" {
  desired_capacity    = 1
  max_size            = 5
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.public[0].id, aws_subnet.public[1].id, aws_subnet.public[2].id]

  launch_template {
    id      = aws_launch_template.application_launch_template.id
    version = "$Latest"
  }

  target_group_arns         = [aws_lb_target_group.app_target_group.arn]
  health_check_type         = "EC2"
  health_check_grace_period = 300
  default_cooldown          = 60

  tag {
    key                 = "Name"
    value               = "application-instance"
    propagate_at_launch = true
  }

  # dependency
  depends_on = [aws_db_instance.rds_instance]
}