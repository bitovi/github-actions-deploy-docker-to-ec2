#!/bin/bash

# """
# This bash script uses Terraform to output the values of environment 
# variables and store them in a file called bo-out.env. 
# The script checks if Terraform is being used to destroy the environment, and if not, 
# it runs Terraform output and removes the quotation marks from the output before storing 
# it in the bo-out.env file.
# """

set -x

echo "In afterhook - output.sh"

if [ "$TERRAFORM_DESTROY" != "true" ]; then
    terraform output | sed "s/ = /=/g" | sed "s/\"//g" > /opt/bitops_deployment/bo-out.env
    cat /opt/bitops_deployment/bo-out.env
fi
