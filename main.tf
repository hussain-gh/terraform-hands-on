resource "aws_instance" "example1" {
  ami           = "ami-0e53db6fd757e38c7"
  instance_type = "t2.micro"
}