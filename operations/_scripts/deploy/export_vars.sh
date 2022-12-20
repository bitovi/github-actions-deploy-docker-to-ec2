#!/bin/bash
# Export variables to GHA

for variable in $(cat $GITHUB_ACTION_PATH/operations/bo-out.env); do echo "::set-output name=$variable"; done
