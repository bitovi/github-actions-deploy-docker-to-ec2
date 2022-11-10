# Use the https version (not the SSH version) to pull a public repo
app_repo_clone_url = "https://github.com/bitovi/jira-qa-metrics.git"

# the name of the operations repo environment directory
ops_repo_environment = "jira-qa-metrics"

# Application startup command, could be npm start or any other command
app_cmd_command = "npm run server"

# provide the name of the repo (should correspond to the app_repo_clone_url)
app_repo_name = "jira-qa-metrics"

# provide the name of the configuration file stored in AWS Secret Manager
secret_name = "test-env"

# Path on the instance where the app will be cloned (do not include app_repo_name)
app_install_root = "/home/ubuntu"

# logs
lb_access_bucket_name = "bitovi-jira-qa-metrics-operations-global-tools-lb-access-logs"

# domain stuff
sub_domain_name = "jira-qa-metrics"
domain = "somebitovidomain.com"
