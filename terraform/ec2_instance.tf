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

  tags = {
    Name = "application-instance"
  }
}