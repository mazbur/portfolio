resource "aws_s3_bucket" "site" {
  bucket = local.bucket_name
  tags   = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Versioning is on so a bad deploy can be rolled back, but `aws s3 sync --delete`
# in the deploy workflow means every push leaves behind noncurrent versions and
# delete markers. Without expiry those accumulate forever.
resource "aws_s3_bucket_lifecycle_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  # Lifecycle rules operate on versions, so versioning must settle first.
  depends_on = [aws_s3_bucket_versioning.site]

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    # Applies to every object in the bucket.
    filter {}

    # Keep a month of history — long enough to roll back a bad deploy,
    # short enough that storage stays flat.
    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    # Once every version of a deleted object has expired, drop the leftover
    # delete marker too, otherwise the bucket fills with tombstones.
    expiration {
      expired_object_delete_marker = true
    }

    # Reclaim storage from uploads that failed partway through.
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "cloudfront_s3_access" {
  statement {
    sid    = "AllowCloudFrontOAC"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.cloudfront_s3_access.json

  depends_on = [aws_s3_bucket_public_access_block.site]
}
