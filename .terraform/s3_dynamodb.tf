resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-bucket-henrique1"
}

resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock-table-henrique1"
  hash_key       = "LockID"
  read_capacity  = 5
  write_capacity = 5
  attribute {
    name = "LockID"
    type = "S"
  }
}
