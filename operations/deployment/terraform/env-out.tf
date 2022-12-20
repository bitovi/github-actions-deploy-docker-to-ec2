resource "null_resource" "export-bitops-variables" {
  provisioner "local-exec" {
    command = "echo BO_OUT-vm_url=${local.url} >>"
  }
}


resource "local_file" "export-bitops-variables" {
  filename = format("%s/%s", abspath(path.root), "bo-out.env")
  content  = <<-EOT
vm_url=${local.url}
EOT
}