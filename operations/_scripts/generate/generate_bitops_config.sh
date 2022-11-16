#!/bin/bash

set -e

# TODO: use templating
#    provide '.tf.tmpl' files in the 'operations/deployment' repo
#    and iterate over all of them to provide context with something like jinja
#    Example: https://github.com/mattrobenolt/jinja2-cli
#    jinja2 some_file.tmpl data.json --format=json

echo "In generate_bitops_config.sh"

CONFIG_STACK_ACTION="apply"
if [ "$STACK_DESTROY" == "true" ]; then
  CONFIG_STACK_ACTION="destroy"
fi

echo "
terraform:
    cli: {}
    options:
        stack-action: ${CONFIG_STACK_ACTION}
" >> "${GITHUB_ACTION_PATH}/operations/deployment/terraform/bitops.config.yaml"