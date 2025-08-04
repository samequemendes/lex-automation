#!/bin/bash
set -e

TARGET_PROFILE="AdministratorAccess-743065069150"
REGION="us-east-1"
ROLE_ARN_DESTINO="arn:aws:iam::743065069150:role/aws-service-role/lexv2.amazonaws.com/AWSServiceRoleForLexV2Bots_DONN7R45L2U"

echo "📥 Iniciando importação..."
aws lexv2-models start-import \
  --profile "$TARGET_PROFILE" \
  --file-binaries fileb://bot-export.zip \
  --import-idempotency-token "import-$(date +%s)" \
  --resource-specification \
    "{\"botImportSpecification\":\
{\"botName\":\"BotImportado\",\
\"roleArn\":\"$ROLE_ARN_DESTINO\",\
\"dataPrivacy\":{\"childDirected\":false},\
\"idleSessionTTLInSeconds\":300}}" \
  --merge-strategy FailOnConflict \
  --file-format LexJson \
  --cli-binary-format raw-in-base64-out \
  --output json \
  --region "$REGION" > import-output.json

echo "📄 Conteúdo de import-output.json:"
cat import-output.json

IMPORT_ID=$(jq -r '.importId' import-output.json)
if [[ -z "$IMPORT_ID" || "$IMPORT_ID" == "null" ]]; then
  echo "❌ Nenhum importId encontrado. A importação pode ter falhado."
  exit 1
fi

echo "✅ importId recebido: $IMPORT_ID"
echo "⏳ Aguardando conclusão da importação..."
while true; do
  STATUS=$(aws lexv2-models describe-import \
    --profile "$TARGET_PROFILE" \
    --import-id "$IMPORT_ID" \
    --region "$REGION" \
    --query 'importStatus' --output text)
  echo "Status: $STATUS"
  if [[ "$STATUS" == "Completed" ]]; then
    echo "✅ Importação concluída com sucesso!"
    break
  fi
  if [[ "$STATUS" == "Failed" ]]; then
    echo "❌ Importação falhou."
    aws lexv2-models describe-import \
      --profile "$TARGET_PROFILE" \
      --import-id "$IMPORT_ID" \
      --region "$REGION" \
      --query 'failureReason' --output text
    exit 1
  fi
  sleep 5
done
