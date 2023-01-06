#!/bin/bash
# Export variables to GHA

BO_OUT="$GITHUB_ACTION_PATH/operations/bo-out.env"

echo "Check for $BO_OUT"
if [ -f $BO_OUT ]; then
  echo "Outputting bo-out.env to GITHUB_OUTPUT"
  cat $BO_OUT >> $GITHUB_OUTPUT
else
  echo "BO_OUT is not a file"
fi