#!/bin/bash

set -e

echo ""
echo "In beforehook - 0test.sh"

echo "ls"
ls -al

echo "pwd"
pwd

echo "ls BITOPS_OPSREPO_ENVIRONMENT_DIR"
ls -al $BITOPS_OPSREPO_ENVIRONMENT_DIR
exit 1