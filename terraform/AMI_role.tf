# create role
resource "aws_iam_role" "ec2_role" {
  name = "application-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# S3 and cloudwatch policy
resource "aws_iam_policy" "s3_cloudwatch_policy" {
  name        = "application-ec2-s3-cloudwatch-policy"
  description = "Policy to allow access to a specific S3 bucket, SNS, and CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # S3 bucket permissions
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"],
        Resource = "arn:aws:s3:::${aws_s3_bucket.my_bucket.bucket}"
      },
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"],
        Resource = "arn:aws:s3:::${aws_s3_bucket.my_bucket.bucket}/*"
      },
      # CloudWatch permissions for logging and metrics
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "sns:Publish"
        ],
        "Resource" : "arn:aws:sns:*:*:*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_cloudwatch_policy.arn
}

# lambda function role
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # CloudWatch Logs permissions for monitoring
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      # EC2 permissions for VPC access (ENI management)
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = "*"
      },
      # SNS permissions for publishing messages
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = "arn:aws:sns:*:*:*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}