#!/bin/bash
PROFILE="{{ profile_aws}}"
REGION="us-east-1"

aws lexv2-models list-bots \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query "botSummaries[*].[botId,botName]" \
  --output table
