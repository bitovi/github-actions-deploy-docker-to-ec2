#!/bin/bash

echo "In output.sh"

tf output | sed "s/ = /=/g" | sed "s/\"//g" > /opt/bitops_deployment/bo-out.env

cat /opt/bitops_deployment/bo-out.env