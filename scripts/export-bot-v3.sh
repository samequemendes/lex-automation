#!/bin/bash
set -e

BOT_NAME="$1"
REGION="us-east-1"
PROFILE="AdministratorAccess-743065069150"

if [ -z "$BOT_NAME" ]; then
  echo "❌ Nome do bot não informado!"
  echo "Uso: ./export-bot.sh <NOME_DO_BOT>"
  exit 1
fi

BOT_ID=$(aws lexv2-models list-bots \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query "botSummaries[?botName=='$BOT_NAME'].botId" \
  --output text)

if [ -z "$BOT_ID" ]; then
  echo "❌ Bot '$BOT_NAME' não encontrado."
  exit 1
fi

echo "📦 Exportando bot '$BOT_NAME' (ID: $BOT_ID)..."

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
