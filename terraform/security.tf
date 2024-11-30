resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&()*+-.:;<=>?[]^_{|}~"
}

resource "aws_kms_key" "kms_secrets_manager" {
  description              = "KMS key for Secrets Manager"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 30
  enable_key_rotation      = true
  # rotation_period_in_days  = 90
}

resource "aws_kms_key_policy" "kms_secrets_manager_policy" {
  key_id = aws_kms_key.kms_secrets_manager.key_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # root full access
      {
        "Sid" : "AllowRootFullAccess",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : aws_kms_key.kms_secrets_manager.arn
      },
      # Secrets Manager access
      {
        "Sid" : "AllowSecretsManagerServiceAccess",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "secretsmanager.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : aws_kms_key.kms_secrets_manager.arn # prevent cycle dependence
      }
    ]
  })
}

resource "aws_kms_key" "kms_ec2" {
  description              = "KMS key for EC2 EBS volume encryption"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 30
  enable_key_rotation      = true
}

resource "aws_kms_key_policy" "kms_ec2_policy" {
  key_id = aws_kms_key.kms_ec2.key_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Sid" : "AllowRootFullAccess",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : aws_kms_key.kms_ec2.arn
      },
      # Auto Scaling Service-Linked Role access with AWSServiceRoleForAutoScaling
      {
        "Sid" : "AllowServiceLinkedRoleUseOfKey",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : aws_kms_key.kms_ec2.arn
      },
      {
        "Sid": "Allow attachment of persistent resources",
        "Effect": "Allow",
        "Principal": {
            "AWS": [
                "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
            ]
        },
        "Action": [
            "kms:CreateGrant"
        ],
        "Resource": "*",
        "Condition": {
            "Bool": {
                "kms:GrantIsForAWSResource": true
            }
          }
      }
    ]
  })
}

resource "aws_kms_key" "kms_rds" {
  description              = "KMS key for RDS encryption"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 30
  enable_key_rotation      = true
}

resource "aws_kms_key_policy" "kms_rds_policy" {
  key_id = aws_kms_key.kms_rds.key_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Sid" : "AllowRootFullAccess",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : aws_kms_key.kms_rds.arn
      },
      # RDS service access
      {
        "Sid" : "AllowRDSServiceAccess",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "rds.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : aws_kms_key.kms_rds.arn
      },
      {
        "Sid": "Allow attachment of persistent resources",
        "Effect": "Allow",
        "Principal": {
            "AWS": [
                "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"
            ]
        },
        "Action": [
            "kms:CreateGrant"
        ],
        "Resource": "*",
        "Condition": {
            "Bool": {
                "kms:GrantIsForAWSResource": true
            }
          }
      }
    ]
  })
}

resource "aws_kms_key" "kms_s3" {
  description              = "KMS key for S3 bucket encryption"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 30
  enable_key_rotation      = true
}

resource "aws_kms_key_policy" "kms_s3_policy" {
  key_id = aws_kms_key.kms_s3.key_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Root 
      {
        "Sid" : "AllowRootFullAccess",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : aws_kms_key.kms_s3.arn
      },
      # S3
      {
        "Sid" : "AllowS3ServiceAccess",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "s3.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : aws_kms_key.kms_s3.arn
      }
    ]
  })
}

resource "aws_secretsmanager_secret" "webapp_secret" {
  name        = "webapp-secret-v6" # name conflit
  description = "An example secret for storing sensitive data"
  kms_key_id  = aws_kms_key.kms_secrets_manager.id

  tags = {
    Environment = var.sub_domain
    Application = "my-web-app"
  }
}




# store the secrets into Secrets Manager
resource "aws_secretsmanager_secret_version" "webapp_secret_version" {
  secret_id = aws_secretsmanager_secret.webapp_secret.id
  secret_string = jsonencode({
    database_password = random_password.db_password.result
    sendgrid_api_key  = var.SENDGRID_API_KEY
    domain_name       = "${var.sub_domain}.${var.top_level_domain}"
    from_email        = "no-reply@${var.sub_domain}.${var.top_level_domain}"
  })
}

resource "aws_kms_alias" "alias_kms_secrets_manager" {
  name          = "alias/secrets-manager-key-v1"
  target_key_id = aws_kms_key.kms_secrets_manager.id
}

resource "aws_kms_alias" "alias_kms_ec2" {
  name          = "alias/ec2-ebs-key-v1"
  target_key_id = aws_kms_key.kms_ec2.id
}

resource "aws_kms_alias" "alias_kms_s3" {
  name          = "alias/s3-key-v1"
  target_key_id = aws_kms_key.kms_s3.id
}

resource "aws_kms_alias" "alias_kms_rds" {
  name          = "alias/rds-key-v1"
  target_key_id = aws_kms_key.kms_rds.id
}
