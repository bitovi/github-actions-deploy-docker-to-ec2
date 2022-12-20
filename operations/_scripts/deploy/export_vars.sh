#!/bin/bash
# Export variables to GHA

for variable in $(cat $GITHUB_WORKSPACE/bo-out.env); do echo $variable >> $GITHUB_ENV; done
