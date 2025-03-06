resource "aws_sns_topic" "nasa_topic" {
  name = "nasa-cloud-project-topic"

  tags = var.common_tags
}

resource "aws_sns_topic_subscription" "nasa_topic_subscription" {
  topic_arn = aws_sns_topic.nasa_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.nasa_queue.arn
}