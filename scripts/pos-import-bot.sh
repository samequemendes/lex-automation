#!/bin/bash
set -e

BOT_NAME="BotImportado2"
REGION="us-east-1"
PROFILE="AdministratorAccess-743065069150"
ALIAS_NAME="prod"

echo "🔍 Buscando botId do bot: $BOT_NAME..."
BOT_ID=$(aws lexv2-models list-bots \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query "botSummaries[?botName=='$BOT_NAME'].botId" \
  --output text)

if [ -z "$BOT_ID" ]; then
  echo "❌ Bot não encontrado!"
  exit 1
fi

echo "✅ botId localizado: $BOT_ID"
echo "🚀 Criando nova versão do bot..."

VERSION=$(aws lexv2-models create-bot-version \
  --bot-id "$BOT_ID" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --bot-version-locale-specification '{"pt_BR":{"sourceBotVersion":"DRAFT"}}' \
  --query 'botVersion' \
  --output text)

echo "✅ Versão criada: $VERSION"
echo "⏳ Aguardando o status da versão ficar 'Available'..."

while true; do
  STATUS=$(aws lexv2-models describe-bot-version \
    --bot-id "$BOT_ID" \
    --bot-version "$VERSION" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --query 'botStatus' \
    --output text)

  echo "📌 Status da versão: $STATUS"

  if [[ "$STATUS" == "Available" ]]; then
    echo "✅ Bot version $VERSION está disponível."
    break
  elif [[ "$STATUS" == "Failed" ]]; then
    echo "❌ Criação da versão falhou!"
    exit 1
  fi

  sleep 5
done

echo "🔁 Criando alias '$ALIAS_NAME' apontando para a versão $VERSION..."

BOT_ALIAS_ID=$(aws lexv2-models create-bot-alias \
  --bot-id "$BOT_ID" \
  --bot-alias-name "$ALIAS_NAME" \
  --bot-version "$VERSION" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query 'botAliasId' \
  --output text)

echo "✅ Alias criado: $ALIAS_NAME (ID: $BOT_ALIAS_ID)"

echo "⏳ Verificando status do alias..."

while true; do
  STATUS=$(aws lexv2-models describe-bot-alias \
    --bot-id "$BOT_ID" \
    --bot-alias-id "$BOT_ALIAS_ID" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --query 'botAliasStatus' \
    --output text)

  echo "📌 Status atual do alias: $STATUS"

  if [[ "$STATUS" == "Available" ]]; then
    echo "✅ Alias pronto para uso!"
    break
  elif [[ "$STATUS" == "Failed" ]]; then
    echo "❌ Criação do alias falhou!"
    exit 1
  fi
  sleep 5
done

echo ""
echo "🎉 Bot pronto para uso!"
echo "🔗 Informações:"
echo "   - botId: $BOT_ID"
echo "   - botVersion: $VERSION"
echo "   - alias: $ALIAS_NAME (ID: $BOT_ALIAS_ID)"
