#METADATA PROCESSING LAMBDA
resource "aws_lambda_function" "image_processor_lambda" {
  function_name = "nasa-daily-image-processor"
  runtime       = "python3.9"
  handler       = "image_processor_lambda.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 30

  filename      = "../image_processor_lambda.zip"
  source_code_hash = filebase64sha256("../image_processor_lambda.zip")

  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.nasa_bucket.id
    }
  }

  layers = [aws_lambda_layer_version.requests_layer.arn]
}

resource "aws_lambda_permission" "sqs_trigger" {
  statement_id  = "AllowSQSTrigger"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_processor_lambda.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.nasa_queue.arn
}

resource "aws_lambda_event_source_mapping" "sqs_event_source" {
  event_source_arn = aws_sqs_queue.nasa_queue.arn
  function_name    = aws_lambda_function.image_processor_lambda.arn
  batch_size       = 1
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_image_processor_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_apod_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.nasa_bucket.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:DeleteMessage",
          "sqs:ReceiveMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = aws_sqs_queue.nasa_queue.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "image_processor_logs" {
  name              = "/aws/lambda/${aws_lambda_function.image_processor_lambda.function_name}"
  retention_in_days = 7
}


resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_layer_version" "requests_layer" {
  layer_name          = "requests"
  compatible_runtimes = ["python3.9"]
  filename            = "../requests_layer.zip"
}

# Email lambda
resource "aws_lambda_function" "nasa_email_lambda" {
  function_name = "send_nasa_email"
  runtime       = "python3.9"
  handler = "nasa_email_lambda.nasa_email_lambda.lambda_handler"
  timeout       = 30
  role          = aws_iam_role.lambda_exec.arn

  filename      = "../nasa_email_lambda.zip"
  source_code_hash = filebase64sha256("../nasa_email_lambda.zip")

  environment {
    variables = {
      SES_SENDER_EMAIL    = "henryphcog@gmail.com"
      DB_SECRET_NAME = "pgsql_access_nasaws_db"
    }
  }

  layers = [
    "arn:aws:lambda:sa-east-1:898466741470:layer:psycopg2-py39:1"
  ]

}

resource "aws_lambda_permission" "allow_sns_to_invoke_lambda" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.nasa_email_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.nasa_email_topic.arn
}

resource "aws_sns_topic_subscription" "email_lambda_subscription" {
  topic_arn = aws_sns_topic.nasa_email_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.nasa_email_lambda.arn
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_cloudwatch_log_group" "nasa_email_logs" {
  name              = "/aws/lambda/${aws_lambda_function.nasa_email_lambda.function_name}"
  retention_in_days = 7
}

resource "aws_iam_policy" "lambda_exec_policy" {
  name = "lambda_exec_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = "arn:aws:s3:::*"
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "arn:aws:secretsmanager:::*"
      },
      {
        "Effect": "Allow",
        "Action":  [
          "lambda:GetLayerVersion"
        ],
        "Resource": "arn:aws:lambda:sa-east-1:898466741470:layer:psycopg2-py39:1"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execute_ses_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_execute_logstream_custom_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}
