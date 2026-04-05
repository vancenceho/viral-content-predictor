# S3 bucket
resource "aws_s3_bucket" "data" {
    bucket = "viral-content-predictor"
    force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "data" {
    bucket = aws_s3_bucket.data.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

locals {
    data_prefixes = [
        "data/raw/",
        "data/cleaned/",
        "data/processed/",
    ]
}

resource "aws_s3_object" "data_prefix_markers" {
    for_each = toset(local.data_prefixes)

    bucket = aws_s3_bucket.data.id
    key = each.key
    content = ""
}