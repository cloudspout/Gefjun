data "archive_file" "light" {
  type        = "zip"
  source_dir = "../src/javascript/"
  output_path = "${path.root}/.terraform/tmp/light.zip"
}

resource "aws_s3_bucket_object" "light" {
  bucket = aws_s3_bucket._.bucket
  key    = "${terraform.workspace}/light/index.zip"

  source = data.archive_file.light.output_path
  etag   = filemd5(data.archive_file.light.output_path)

  content_type = "application/zip"
}
