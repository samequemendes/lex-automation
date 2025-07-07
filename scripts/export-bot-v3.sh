#!/bin/bash
set -e

BOT_ID="$1"
REGION="us-east-1"
PROFILE="AdministratorAccess-743065069150"

if [ -z "$BOT_ID" ]; then
  echo "❌ ID do bot não informado!"
  echo "Uso: ./export-bot-v3.sh <ID_DO_BOT>"
  exit 1
fi

echo "📦 Exportando bot com ID: $BOT_ID..."

EXPORT_ID=$(aws lexv2-models create-export \
  --resource-specification "botExportSpecification={botId=$BOT_ID,botVersion=DRAFT}" \
  --file-format LexJson \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query 'exportId' \
  --output text)

while true; do
  STATUS=$(aws lexv2-models describe-export \
    --export-id "$EXPORT_ID" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --query 'exportStatus' \
    --output text)
  echo "Status: $STATUS"
  [[ "$STATUS" == "Completed" ]] && break
  [[ "$STATUS" == "Failed" ]] && echo "❌ Exportação falhou." && exit 1
  sleep 5
done

DOWNLOAD_URL=$(aws lexv2-models describe-export \
  --export-id "$EXPORT_ID" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query 'downloadUrl' \
  --output text)

curl -s -L "$DOWNLOAD_URL" -o "bot-export.zip"
echo "✅ Bot exportado com sucesso para 'bot-export.zip'"
