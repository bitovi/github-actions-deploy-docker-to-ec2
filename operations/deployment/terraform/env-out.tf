resource "local_file" "export-bitops-variables" {
  filename = format("%s/%s", abspath(path.root), "/opt/bitops_deployment/bo-out.env")
  content  = <<-EOT
vm_url=${local.url}
EOT
}