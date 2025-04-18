resource "aws_s3_bucket" "nasa_bucket" {
  bucket = "nasa-cloud-project-bucket"

  tags = var.common_tags
}

resource "aws_s3_bucket_notification" "nasa_s3_notification" {
  bucket = aws_s3_bucket.nasa_bucket.id

  topic {
    topic_arn = aws_sns_topic.nasa_email_topic.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
