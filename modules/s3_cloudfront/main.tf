terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.60.0"
    }
  }
}

resource "aws_s3_bucket" "uploads" {
  bucket = "${var.name_prefix}-uploads-${var.environment}-${var.suffix}"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning { enabled = true }

  lifecycle_rule {
    id = "expire-old-versions"
    enabled = true
    noncurrent_version_expiration { days = 30 }
  }
}

resource "aws_s3_bucket_policy" "uploads_policy" {
  bucket = aws_s3_bucket.uploads.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid = "AllowCloudFrontServicePrincipalReadOnly"
      Effect = "Allow"
      Principal = { Service = "cloudfront.amazonaws.com" }
      Action = "s3:GetObject"
      Resource = "${aws_s3_bucket.uploads.arn}/*"
    }]
  })
}
