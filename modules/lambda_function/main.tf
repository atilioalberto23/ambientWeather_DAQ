resource "aws_iam_role" "lambda_role" {
  name = "${var.name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${var.bucket}/*"
      }
    ]
  })
}

resource "aws_lambda_function" "this" {
  function_name = var.name
  handler       = "ambientweather.lambda_handler"
  runtime       = "python3.12"
  role          = var.role_arn

  filename         = "${path.module}/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")

  environment {
    variables = {
      API_KEY = var.api_key
      APP_KEY = var.app_key
      BUCKET  = var.bucket
    }
  }
}