resource "aws_instance" "application" {
  ami                         = data.aws_ami.latest_ami.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.application_sg.id]
  associate_public_ip_address = true

  key_name = var.key_pair_name

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo mkdir -p /etc/webapp
              echo "DB_URL=jdbc:mysql://${aws_db_instance.rds_instance.endpoint}/csye6225" | sudo tee -a /etc/webapp/.env
              echo "DB_USERNAME=${var.db_username}" | sudo tee -a /etc/webapp/.env
              echo "DB_PASSWORD=${var.db_password}" | sudo tee -a /etc/webapp/.env
              EOF

  tags = {
    Name = "application-instance"
  }
  depends_on = [aws_db_instance.rds_instance]
}


# rds instance
resource "aws_db_instance" "rds_instance" {
  identifier        = "csye6225"
  engine            = "mysql"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "csye6225"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.csye6225_mysql.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = false
  multi_az            = false
  skip_final_snapshot = true
}