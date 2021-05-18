provider "aws" {
   region  = "us-east-2"
   access_key = var.access_key
   secret_key = var.secret_key
 }

resource "aws_instance" "example" {
   ami           = "ami-01ed306a12b7d1c96"
   instance_type = "t2.micro"
}
