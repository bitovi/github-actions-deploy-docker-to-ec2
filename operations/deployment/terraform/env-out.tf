# resource "local_file" "export-bitops-variables" {
#   filename = "/opt/bitops_deployment/bo-out.env"
#   content  = <<-EOT
# vm_url=${local.url}
# efs_url=${local.efs_url}
# EOT
# }