resource "aws_sns_topic" "nasa_topic" {
  name = "nasa-cloud-project-topic"

  tags = var.common_tags
}

resource "aws_sns_topic_subscription" "nasa_topic_subscription" {
  topic_arn = aws_sns_topic.nasa_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.nasa_queue.arn
}

resource "aws_sns_topic" "nasa_email_topic" {
  name = "nasa-email-topic"
  tags = var.common_tags
}

resource "aws_sns_topic_subscription" "nasa_email_lambda_subscription" {
  topic_arn = aws_sns_topic.nasa_email_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.nasa_email_lambda.arn
}

resource "aws_sns_topic_policy" "nasa_sns_policy" {
  arn = aws_sns_topic.nasa_email_topic.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = "SNS:Publish",
        Resource = aws_sns_topic.nasa_email_topic.arn,
        Condition = {
          ArnLike = {
            "aws:SourceArn": aws_s3_bucket.nasa_bucket.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket.nasa_bucket, aws_sns_topic.nasa_email_topic]
}