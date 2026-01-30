# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = var.ec2_ami_id
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]

  associate_public_ip_address = true

  tags = {
    Name = "aws_tf_cicd"
  }

  lifecycle {
    create_before_destroy = true
  }
}
