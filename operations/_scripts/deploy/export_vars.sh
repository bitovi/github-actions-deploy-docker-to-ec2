#!/bin/bash
# Export variables to GHA

find /home/runner/work -iname bo-out.env
echo "List dirs"
ls -lah 
echo "List GHA PATH"
ls -lah $GITHUB_ACTION_PATH
echo "LIST ENV_VARS"
env

for variable in $(cat $GITHUB_WORKSPACE/bo-out.env); do echo $variable >> $GITHUB_ENV; done
