#!/bin/bash
# Export variables to GHA

find . -iname bo-out.env
ls -lah
for variable in $(cat $GITHUB_WORKSPACE/bo-out.env); do echo $variable >> $GITHUB_ENV; done
