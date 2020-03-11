resource "aws_s3_bucket" "_" {
  bucket = "gefjun-${terraform.workspace}"
  acl    = "private"

  versioning {
    enabled = true
  }
}
