## AWS Provider
provider "aws" {
  region     = var.aws_region
}

## Localhost Provider
# provider "aws" {
#   region                      = "us-east-1"
#   access_key                  = "ph"
#   secret_key                  = "ph"
#   skip_credentials_validation = true
#   skip_requesting_account_id  = true
#   skip_metadata_api_check     = true
#   s3_use_path_style = true
#
#   endpoints {
#     sns = "http://localhost:4566"
#     sqs = "http://localhost:4566"
#     s3  = "http://localhost:4566"
#     ec2 = "http://localhost:4566"
#     lambda = "http://localhost:4566"
#   }
# }