resource "aws_lambda_function" "this" {
  function_name = var.name
  role          = var.role_arn
  handler       = "ambientweather.lambda_handler"
  runtime       = "python3.12"
  timeout       = 30

  filename = "${path.module}/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")

  environment {
    variables = {
      API_KEY = var.api_key
      APP_KEY = var.app_key
      BUCKET  = var.bucket
    }
  }
}