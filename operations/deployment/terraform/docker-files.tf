resource "local_file" "docker-compose" {
  filename = "${path.module}/docker-compose.yaml"
  file_permission = "666"
  content  = <<-EOT
---
version: '3.9'
services:
  app:
    container_name: ${var.app_repo_name}
    env_file: .env
    restart: always
    build: .
    volumes:
      - .:/app
      # needed for the deployment. comment out if you want to manage node_modules from your local machine
      # better approach: if you need to add or remove node_modules, just rebuild the image `docker-compose up --build`
      - /app/node_modules
    stdin_open: true
    tty: true
EOT
}

resource "local_file" "dockerfile" {
  filename = "${path.module}/Dockerfile"
  file_permission = "666"
  content  = <<-EOT
FROM node:18-alpine
ENV PORT=${local.environment.PORT}

WORKDIR app
COPY . .

COPY package.json .
COPY package-lock.json .
RUN npm ci

EXPOSE $PORT
CMD ${var.app_cmd_command}
EOT
}
