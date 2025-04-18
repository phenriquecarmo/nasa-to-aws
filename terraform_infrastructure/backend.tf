terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-henrique1"
    key            = "nasaws/.terraform/terraform.tfstate"
    region         = "sa-east-1"
    dynamodb_table = "terraform-lock-table-henrique1"
  }
}