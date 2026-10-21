variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
  validation {
    condition     = var.aws_region == "ap-southeast-1"
    error_message = "Lab chi cho phep Singapore ap-southeast-1."
  }
}

variable "availability_zone" {
  type    = string
  default = "ap-southeast-1a"
  validation {
    condition     = can(regex("^ap-southeast-1[a-z]$", var.availability_zone))
    error_message = "AZ phai thuoc ap-southeast-1."
  }
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
  validation {
    condition     = var.instance_type == "t3.micro"
    error_message = "Policy lab chi cho phep t3.micro."
  }
}

variable "environment" {
  type    = string
  default = "dev"
  validation {
    condition     = var.environment == "dev"
    error_message = "Policy lab yeu cau Environment=dev."
  }
}

variable "bucket_name" {
  type    = string
  default = "demo-web-assets-565856126571-dev"
  validation {
    condition     = var.bucket_name == "demo-web-assets-565856126571-dev"
    error_message = "Ten bucket phai khop ARN trong policy lab."
  }
}
