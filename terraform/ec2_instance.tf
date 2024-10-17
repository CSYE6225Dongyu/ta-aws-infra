resource "aws_instance" "application" {
  ami                         = data.aws_ami.latest_ami.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.application_sg.id]
  associate_public_ip_address = true

  key_name = var.key_pair_name

  tags = {
    Name = "application-instance"
  }
}