#!/bin/bash
set -e
TARGET_PROFILE="AdministratorAccess-743065069150"
REGION="us-east-1"
ROLE_ARN_DESTINO="arn:aws:iam::743065069150:role/aws-service-role/lexv2.amazonaws.com/AWSServiceRoleForLexV2Bots_DONN7R45L2U"

# aws lexv2-models start-import \
#   --profile "$TARGET_PROFILE" \
#   --import-idempotency-token "import-$(date +%s)" \
#   --resource-specification "{\"botImportSpecification\":{\"botName\":\"BotImportado\",\"roleArn\":\"$ROLE_ARN_DESTINO\",\"dataPrivacy\":{\"childDirected\":false},\"idleSessionTTLInSeconds\":300}}" \
#   --merge-strategy FailOnConflict \
#   --file-format LexJson \
#   --cli-binary-format raw-in-base64-out \
#   --file-binaries fileb://bot-export.zip \
#   --output json \
#   --region "$REGION" > import-output.json


  aws lexv2-models start-import \
  --profile "AdministratorAccess-743065069150" \
  --file-binaries fileb://bot-export.zip \
  --import-idempotency-token "import-$(date +%s)" \
  --resource-specification "{\"botImportSpecification\":{\"botName\":\"BotImportado\",\"roleArn\":\"$ROLE_ARN_DESTINO\",\"dataPrivacy\":{\"childDirected\":false},\"idleSessionTTLInSeconds\":300}}" \
  --merge-strategy FailOnConflict \
  --file-format LexJson \
  --cli-binary-format raw-in-base64-out \
  --output json \
  --region "us-east-1"