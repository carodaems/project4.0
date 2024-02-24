resource "aws_s3_bucket" "ai-s3" {
  bucket = "ai-s3bucket-j3"
  lifecycle {
    ignore_changes = [
      bucket, # Ignores any changes to the bucket itself
    ]
  }
}

resource "aws_s3_account_public_access_block" "account_public_access" {
  block_public_acls   = false
  block_public_policy = false
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access" {
  bucket = "ai-s3bucket-j3"

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "allow_access" {
  bucket = "ai-s3bucket-j3"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement1",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${data.aws_caller_identity.current.account_id}"
            },
            "Action": "s3:GetObject",
            "Resource": [
                "${aws_s3_bucket.ai-s3.arn}/*",
                "${aws_s3_bucket.ai-s3.arn}",
                "${aws_s3_bucket.ai-s3.arn}/labelencoder/*",
                "${aws_s3_bucket.ai-s3.arn}/data/*"
            ]
        },
        {
            "Sid": "Statement2",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${data.aws_caller_identity.current.account_id}"
            },
            "Action": "s3:ListBucket",
            "Resource": [
                "${aws_s3_bucket.ai-s3.arn}",
                "${aws_s3_bucket.ai-s3.arn}/model"
            ]
        },
        {
            "Sid": "Statement3",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${data.aws_caller_identity.current.account_id}"
            },
            "Action": "s3:PutObject",
            "Resource": [
                "${aws_s3_bucket.ai-s3.arn}/model/*",
                "${aws_s3_bucket.ai-s3.arn}/labelencoder/*",
                "${aws_s3_bucket.ai-s3.arn}/data/*"
            ]
        }
    ]
}
EOF
}
