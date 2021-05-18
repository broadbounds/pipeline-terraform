provider "aws" {
   region  = "us-east-2"
 }

resource "aws_instance" "example" {
   ami           = "ami-07a3e3eda401f8caa"
   instance_type = "t2.micro"
}
