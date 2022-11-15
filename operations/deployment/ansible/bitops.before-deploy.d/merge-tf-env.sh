#!/bin/bash
echo "BitOps Ansible before script: Merge Terraform Enviornment Variables..."

# dotenv file
DOTENV_FILE="${BITOPS_ENVROOT}/ansible/app.env"

# tf dotenv file
TF_DOTENV_FILE="${BITOPS_ENVROOT}/terraform/tf.env"

echo "DEBUGGING"
echo "cat DOTENV_FILE ($DOTENV_FILE)"
cat $DOTENV_FILE


TEMP_DOTENV_FILE="${BITOPS_ENVROOT}/ansible/tmp.env"

cat $TF_DOTENV_FILE >> $TEMP_DOTENV_FILE
cat $DOTENV_FILE >> $TEMP_DOTENV_FILE
cat $TEMP_DOTENV_FILE > $DOTENV_FILE

echo "cat TEMP_DOTENV_FILE ($TEMP_DOTENV_FILE)"
cat $TEMP_DOTENV_FILE