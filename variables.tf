# Used us-east-1 for testing purposes, could swap out for eu-central-1
variable "availability_zone" {
  description = "availability zone"
  default = "us-east-1" 
}

variable "az1" {
  description = "availability zone"
  default = "us-east-1a" 
}

variable "az2" {
  description = "availability zone"
  default = "us-east-1b" 
}

variable "public_subnet_ids" {
  default = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id, aws_subnet.public-subnet-3]
  type    = "list"
}

variable "private_subnet_ids" {
  default = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id, aws_subnet.private-subnet-3]
  type    = "list"
}