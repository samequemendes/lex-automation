#!/bin/bash
set -e

REGION="us-east-1"
PROFILE="AdministratorAccess-743065069150"

aws lexv2-models list-bots \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query "botSummaries[].{Name:botName,Status:botStatus}" \
  --output table
