variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "sa-east-1"
}

variable "common_tags" {
  description = "My Tag to hold all resources"
  type        = map(string)
  default = {
    Name        = "NasaCloudProject"
    Environment = "Dev"
  }
}

variable "ec2_ssh_key" {
  description = "The public SSH key for EC2 access"
  type        = string
}
