#!/bin/bash

set -x

echo "In afterhook - output.sh"

printenv
if [ "$STACK_DESTROY" != "true" ]; then
    terraform output | sed "s/ = /=/g" | sed "s/\"//g" > /opt/bitops_deployment/bo-out.env
    cat /opt/bitops_deployment/bo-out.env
fi