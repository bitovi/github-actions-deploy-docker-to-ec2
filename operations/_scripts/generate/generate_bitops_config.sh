#!/bin/bash

set -e

echo "In generate_bitops_config.sh"

CONFIG_STACK_ACTION="apply"
if [ "$STACK_DESTROY" == "true" ]; then
  CONFIG_STACK_ACTION="destroy"
fi

targets=
if [ -n "$TERRAFORM_TARGETS" ]; then
  targets="targets:\n"
  # Iterate over the provided comma-delimited string
  for item in $(echo $TERRAFORM_TARGETS | sed "s/,/ /g"); do
    # Add the item to the YAML list
    targets="$targets\t  - $item\n"
  done
fi

echo -e "
terraform:
    cli:
        stack-action: ${CONFIG_STACK_ACTION}
        $targets
    options: {}
" >> "${GITHUB_ACTION_PATH}/operations/deployment/terraform/bitops.config.yaml"