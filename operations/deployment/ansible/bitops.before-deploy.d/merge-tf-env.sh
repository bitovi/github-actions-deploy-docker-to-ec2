#!/bin/bash

set -e


echo "BitOps Ansible before script: Merge Terraform Enviornment Variables..."

# Merging order
order=tf,repo,ghs,aws

# Ansible dotenv file -> The final destination of all
DOTENV_FILE="${BITOPS_ENVROOT}/ansible/app.env"

# TF dotenv file
TF_DOTENV_FILE="${BITOPS_ENVROOT}/terraform/tf.env"

# Repo env file
REPO_ENV_FILE="${BITOPS_ENVROOT}/ansible/repo.env"

# GH Secrets env file
GHS_ENV_FILE="${BITOPS_ENVROOT}/ansible/ghs.env"

# TF AWS dotenv file
AWS_SECRET_FILE="${BITOPS_ENVROOT}/terraform/aws.env"

# Make sure app.env is empty, if not, delete it and create one.

if [ -f $DOTENV_FILE ]; then 
  rm -rf $DOTENV_FILE
fi 
touch $DOTENV_FILE

# Function to merge to destination

function merge {
  if [ -s $1 ]; then
    echo "Merging $2 envs"
    cat $1 >> $DOTENV_FILE
  else
    echo "Nothing to merge from $2"
  fi
}

# Function to be called based on the input string
function process {
  case $1 in
    aws)
      # Code to be executed for option1
      merge $AWS_SECRET_FILE "AWS Secret"
      ;;
    repo)
      # Code to be executed for option2
      merge $REPO_ENV_FILE "checked-in"
      ;;
    ghs)
      # Code to be executed for option3
      merge $GHS_ENV_FILE "GH-Secret"
      ;;
    tf)
      # Code to be executed for option3
      merge $TF_DOTENV_FILE "Terraform"
      ;;
    *)
      # Code to be executed if no matching option is found
      echo "Invalid option"
      ;;
  esac
}

# Read the input string and split it into an array
IFS=',' read -r -a options <<< "$order"

# Loop through the array and call the process function for each element
for option in "${options[@]}"; do
  process "$option"
done