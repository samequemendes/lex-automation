#!/bin/bash
PROFILE="AdministratorAccess-743065069150"
REGION="us-east-1"

aws lexv2-models list-bots \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query "botSummaries[*].[botId,botName]" \
  --output table
