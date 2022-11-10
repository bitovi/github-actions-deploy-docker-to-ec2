resource "local_file" "api-dotenv" {
  #content = templatefile("api-dotenv.tmpl", {})
  filename = format("%s/%s", abspath(path.root), "api.env")
  content  = <<-EOT
# Port
PORT=${local.environment.PORT}
CLIENT_JIRA_CLIENT_ID=${local.environment.CLIENT_JIRA_CLIENT_ID}
CLIENT_JIRA_SCOPE=${local.environment.CLIENT_JIRA_SCOPE}
CLIENT_JIRA_CALLBACK_URL=${local.environment.CLIENT_JIRA_CALLBACK_URL}
CLIENT_JIRA_API_URL=${local.environment.CLIENT_JIRA_API_URL}
JIRA_CLIENT_SECRET=${local.environment.JIRA_CLIENT_SECRET}
EOT
}

