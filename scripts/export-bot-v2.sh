#!/bin/bash
set -e

# Parâmetros
BOT_NAME="$1"
REGION="us-east-1"
PROFILE="AdministratorAccess-743065069150"

if [ -z "$BOT_NAME" ]; then
  echo "❌ Você precisa informar o nome do bot como argumento."
  echo "Uso: ./scripts/export-bot.sh <NOME_DO_BOT>"
  exit 1
fi

# Obter o botId com base no nome
BOT_ID=$(aws lexv2-models list-bots \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query "botSummaries[?botName=='$BOT_NAME'].botId" \
  --output text)

if [ -z "$BOT_ID" ]; then
  echo "❌ Bot com nome '$BOT_NAME' não encontrado."
  exit 1
fi

echo "📦 Exportando bot '$BOT_NAME' (ID: $BOT_ID)..."

# Criar exportação
EXPORT_ID=$(aws lexv2-models create-export \
  --resource-specification "botExportSpecification={botId=$BOT_ID,botVersion=DRAFT}" \
  --file-format LexJson \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query 'exportId' \
  --output text)

# Aguardar exportação
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

# Obter URL e baixar
DOWNLOAD_URL=$(aws lexv2-models describe-export \
  --export-id "$EXPORT_ID" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query 'downloadUrl' \
  --output text)

curl -s -L "$DOWNLOAD_URL" -o "bot-export.zip"
echo "✅ Bot exportado com sucesso para 'bot-export.zip'"
