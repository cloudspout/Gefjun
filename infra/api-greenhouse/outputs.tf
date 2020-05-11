output "md5sum" {
  value = md5(<<EOT
      ${filemd5("${path.module}/main.tf")}
      ${filemd5("${path.module}/outputs.tf")}
      ${filemd5("${path.module}/variables.tf")}
      module.endponit_light-on.md5sum
      module.endponit_light-off.md5sum
EOT
  )
}

