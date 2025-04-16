# IAM policy document for CloudWatch Logs
data "aws_iam_policy_document" "inline_policy_cloudwatch" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:us-east-1:255945442255:log-group:/aws/lambda/${var.lambda_function_name}:*"]
  }
}

# IAM policy document for X-Ray
data "aws_iam_policy_document" "xray_policy" {
  statement {
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = ["*"]
  }
}

# Assume role policy for Lambda
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# IAM role for Lambda
resource "aws_iam_role" "iam_for_lambda" {
  name               = var.iam_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach CloudWatch logs permissions
resource "aws_iam_role_policy" "cloudwatch_logs" {
  name   = "cloudwatch-logs"
  role   = aws_iam_role.iam_for_lambda.name
  policy = data.aws_iam_policy_document.inline_policy_cloudwatch.json
}

# Attach X-Ray tracing permissions
resource "aws_iam_role_policy" "xray" {
  name   = "lambda-xray-permissions"
  role   = aws_iam_role.iam_for_lambda.name
  policy = data.aws_iam_policy_document.xray_policy.json
}
