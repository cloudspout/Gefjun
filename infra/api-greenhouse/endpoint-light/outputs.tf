output "md5sum" {
  value = md5(<<EOT
      ${filemd5("${path.module}/main.tf")}
      ${filemd5("${path.module}/outputs.tf")}
      ${filemd5("${path.module}/variables.tf")}
EOT
  )
}