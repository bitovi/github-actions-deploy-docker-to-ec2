#!/bin/bash

# """
# What
#   This bash script uses Terraform to output the values of environment 
#   variables and store them in a file called bo-out.env. 
#   The script checks if Terraform is being used to destroy the environment, and if not, 
#   it runs Terraform output and removes the quotation marks from the output before storing 
#   it in the bo-out.env file.
# Why
#   The bo-out.env file is used by Ansible to populate variables passed on by Terraform
# """

#set -x

echo "In afterhook - output.sh"

if [ "$TERRAFORM_DESTROY" != "true" ]; then
    # The sed command will make each variable be in it's line, and in case a list is present, will transform it into a line
    terraform output | sed -e ':a;/["\)]$/!N;s/\n//;ta' -e 's/ *= */=/g;s/[" ,]//g;s/,\([]]\)/\1/g'  > /opt/bitops_deployment/bo-out.env
    cat /opt/bitops_deployment/bo-out.env
fi
