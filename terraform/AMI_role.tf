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
  description = "Policy to allow access to a specific S3 bucket and CloudWatch with StatsD integration"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
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
        Resource = "*",
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_cloudwatch_policy.arn
}