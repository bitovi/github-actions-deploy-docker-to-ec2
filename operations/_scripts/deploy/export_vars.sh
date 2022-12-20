#!/bin/bash
# Export variables to GHA

find / -name bo-out.env
for variable in $(cat $GITHUB_WORKSPACE/bo-out.env); do echo $variable >> $GITHUB_ENV; done
