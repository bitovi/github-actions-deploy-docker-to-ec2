resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = format("%s/%s/%s", abspath(path.root), ".ssh", "bitops-ssh-key.pem")
  file_permission = "0600"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl", {
    ip          = aws_instance.server.public_ip,
    ssh_keyfile = local_sensitive_file.private_key.filename
    app_repo_full_url = local.github_private_link
    app_repo_name = var.app_repo_name
    app_install_root = var.app_install_root
  })
  filename = format("%s/%s", abspath(path.root), "inventory.yaml")
}

