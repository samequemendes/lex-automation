#!/bin/bash
set -e
SOURCE_PROFILE="AdministratorAccess-743065069150"
BOT_ID="WMZQH0M4SQ"
BOT_VERSION="DRAFT"
REGION="us-east-1"

EXPORT_ID=$(aws lexv2-models create-export \
  --profile "$SOURCE_PROFILE" \
  --resource-specification '{"botExportSpecification":{"botId":"'"$BOT_ID"'","botVersion":"'"$BOT_VERSION"'"}}' \
  --file-format LexJson \
  --region "$REGION" | jq -r '.exportId')

while true; do
  STATUS=$(aws lexv2-models describe-export --profile "$SOURCE_PROFILE" --export-id "$EXPORT_ID" --region "$REGION" --query 'exportStatus' --output text)
  echo "Status: $STATUS"
  [[ "$STATUS" == "Completed" ]] && break
  [[ "$STATUS" == "Failed" ]] && echo "❌ Exportação falhou." && exit 1
  sleep 5
done

DOWNLOAD_URL=$(aws lexv2-models describe-export --profile "$SOURCE_PROFILE" --export-id "$EXPORT_ID" --region "$REGION" --query 'downloadUrl' --output text)
curl -s "$DOWNLOAD_URL" -o bot-export.zip