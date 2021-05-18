provider "aws" {
   region  = "us-east-2"
   access_key = var.access_key
   secret_key = var.secret_key
 }

resource "aws_instance" "example" {
   ami           = "ami-07a3e3eda401f8caa"
   instance_type = "t2.micro"
}
