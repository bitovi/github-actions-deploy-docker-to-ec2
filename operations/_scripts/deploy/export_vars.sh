#!/bin/bash
# Export variables to GHA

BO_OUT="$GITHUB_ACTION_PATH/operations/bo-out.env"

if [ -f $BO_OUT ]; then
  cat $BO_OUT >> $GITHUB_OUTPUT
fi