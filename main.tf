provider "aws" {
   region  = "us-east-2"
   access_key = var.access_key
   secret_key = var.secret_key
 }

resource "aws_instance" "example" {
   ami           = "ami-077e31c4939f6a2f3"
   instance_type = "t2.micro"
}
