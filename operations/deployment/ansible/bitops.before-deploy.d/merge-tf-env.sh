#!/bin/bash
echo "BitOps Ansible before script: Merge Terraform Enviornment Variables..."

# dotenv file
DOTENV_FILE="${BITOPS_ENVROOT_DIR}/ansible/app.env"

# tf dotenv file
TF_DOTENV_FILE="${BITOPS_ENVROOT_DIR}/terraform/tf.env"

echo "DEBUGGING"
echo "cat DOTENV_FILE"
cat $DOTENV_FILE
echo "cat TF_DOTENV_FILE"
cat $TF_DOTENV_FILE

cat $TF_DOTENV_FILE >> $DOT_ENV