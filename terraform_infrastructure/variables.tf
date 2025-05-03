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

variable "user_ip" {
  description = "My public IP Address for DB access"
  type = string
}

variable "db_username" {
  description = "RDS DB username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS DB password"
  type        = string
  sensitive   = true
}
