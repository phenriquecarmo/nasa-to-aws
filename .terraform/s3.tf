resource "aws_s3_bucket" "nasa_bucket" {
  bucket = "nasa-cloud-project-bucket"

  tags = var.common_tags
}