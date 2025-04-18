resource "aws_sqs_queue" "nasa_queue" {
  name = "nasa-cloud-project-queue"

  tags = var.common_tags
}

resource "aws_sqs_queue_policy" "nasa_queue_policy" {
  queue_url = aws_sqs_queue.nasa_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.nasa_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.nasa_topic.arn
          }
        }
      }
    ]
  })

}