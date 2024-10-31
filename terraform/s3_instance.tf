# UUID as S3 bucket name
resource "random_uuid" "bucket_name" {}

# create S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket        = random_uuid.bucket_name.result
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my_bucket_encryption" {
  bucket = aws_s3_bucket.my_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # 默认加密方式
    }
  }
}

# user aws_s3_bucket_lifecycle_configuration to set life
resource "aws_s3_bucket_lifecycle_configuration" "my_bucket_lifecycle" {
  bucket = aws_s3_bucket.my_bucket.bucket

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

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