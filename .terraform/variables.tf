variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "region" {
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
