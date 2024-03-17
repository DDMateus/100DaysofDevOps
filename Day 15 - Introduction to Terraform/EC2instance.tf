resource "aws_instance" "ec2_instance" {
  ami                    = "ami-0d7a109bf30624c99"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name               = aws_key_pair.key_pair.id
  subnet_id              = aws_subnet.name.id

  tags = {
    Name = "EC2"
  }
}