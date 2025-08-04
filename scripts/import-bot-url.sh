#!/bin/bash
set -e

# Variáveis
BOT_ZIP="bot-export2.zip"
REGION="us-east-1"
PROFILE="AdministratorAccess-743065069150"
ROLE_ARN_DESTINO="arn:aws:iam::743065069150:role/poc-role-amazon-lex-sameque-mendes"

echo "📦 Verificando arquivo $BOT_ZIP..."
if [ ! -f "$BOT_ZIP" ]; then
  echo "❌ Arquivo $BOT_ZIP não encontrado!"
  exit 1
fi

echo "🔗 Criando upload URL..."
CREATE_OUTPUT=$(aws lexv2-models create-upload-url \
  --region "$REGION" \
  --profile "$PROFILE")

IMPORT_ID=$(echo "$CREATE_OUTPUT" | jq -r '.importId')
UPLOAD_URL=$(echo "$CREATE_OUTPUT" | jq -r '.uploadUrl')

echo "✅ Upload URL criada."
echo "🆔 importId: $IMPORT_ID"
echo "🌐 Enviando arquivo para o Lex..."

curl -s -X PUT "$UPLOAD_URL" \
  -H "Content-Type: application/zip" \
  --upload-file "$BOT_ZIP"

echo "📥 Iniciando importação do bot..."

aws lexv2-models start-import \
  --profile "$PROFILE" \
  --import-id "$IMPORT_ID" \
  --resource-specification "{\"botImportSpecification\":{\"botName\":\"BotImportado2\",\"roleArn\":\"$ROLE_ARN_DESTINO\",\"dataPrivacy\":{\"childDirected\":false},\"idleSessionTTLInSeconds\":300}}" \
  --merge-strategy FailOnConflict \
  --region "$REGION"

echo "⏳ Aguardando conclusão da importação..."
while true; do
  STATUS=$(aws lexv2-models describe-import \
    --import-id "$IMPORT_ID" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --query 'importStatus' \
    --output text)

  echo "📌 Status atual: $STATUS"

  if [[ "$STATUS" == "Completed" ]]; then
    echo "✅ Importação concluída com sucesso!"
    break
  elif [[ "$STATUS" == "Failed" ]]; then
    echo "❌ Importação falhou!"
    aws lexv2-models describe-import \
      --import-id "$IMPORT_ID" \
      --region "$REGION" \
      --profile "$PROFILE" \
      --query 'failureReason' \
      --output text
    exit 1
  fi

  sleep 5
done
