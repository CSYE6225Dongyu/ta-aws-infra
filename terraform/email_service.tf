# pub/sub topic
resource "aws_sns_topic" "verification_topic" {
  name = "email-verification-topic"
}

# SNS Subscription
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.verification_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.email_verification.arn

  # Ensure proper permissions for SNS to invoke Lambda
  depends_on = [aws_lambda_permission.sns_invoke_lambda]
}

# Lambda Function
resource "aws_lambda_function" "email_verification" {
  function_name = "emailVerificationFunction"
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 60

  # Directly use the local zip file for the Lambda function
  filename = "../lambda_function.zip"

  # removed VPC deploy

  # # Add environment variables for RDS connectivity, not needed
  environment {
    variables = {
      SECRET_NAME = aws_secretsmanager_secret.webapp_secret.name
      AWS_REGION = var.aws_region
    }
  }
}

# Lambda Permission for SNS
resource "aws_lambda_permission" "sns_invoke_lambda" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_verification.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.verification_topic.arn
}