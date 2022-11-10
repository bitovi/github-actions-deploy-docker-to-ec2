#!/bin/bash


TF_DOTENV_FILE="$BITOPS_ENVROOT/terraform/api.env"
echo "check for api.env in tf: $TF_DOTENV_FILE"
if [ -f "$TF_DOTENV_FILE" ]; then
  echo "  tf api.env service found"

  echo "copy to ansible"
  cp "$TF_DOTENV_FILE" "$BITOPS_OPSREPO_ENVIRONMENT_DIR/.env"

  echo "check existence"
  ls -al "$BITOPS_OPSREPO_ENVIRONMENT_DIR"
else
  echo "  tf api.env service not found"
fi

TF_COMPOSE_FILE="$BITOPS_ENVROOT/terraform/docker-compose.yaml"
echo "check for docker-compose.yaml in tf: $TF_COMPOSE_FILE"
if [ -f "$TF_COMPOSE_FILE" ]; then
  echo "  tf docker-compose.yaml service found"

  echo "copy to ansible"
  cp "$TF_COMPOSE_FILE" "$BITOPS_OPSREPO_ENVIRONMENT_DIR/docker-compose.yaml"

  echo "check existence"
  ls -al "$BITOPS_OPSREPO_ENVIRONMENT_DIR"
else
  echo "  tf docker-compose.yaml service not found"
fi

TF_DOCKER_FILE="$BITOPS_ENVROOT/terraform/Dockerfile"
echo "check for Dockerfile in tf: $TF_DOCKER_FILE"
if [ -f "$TF_DOCKER_FILE" ]; then
  echo "  tf Dockerfile service found"

  echo "copy Dockerfile to ansible"
  cp "$TF_DOCKER_FILE" "$BITOPS_OPSREPO_ENVIRONMENT_DIR/Dockerfile"

  echo "check Dockerfile existence"
  ls -al "$BITOPS_OPSREPO_ENVIRONMENT_DIR"
else
  echo "  tf Dockerfile service not found"
fi
