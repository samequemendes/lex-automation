#!/bin/bash
set -e

# Variáveis de entrada
BOT_ID="$1"
REGION="us-east-1"
PROFILE="AdministratorAccess-743065069150"
ALIAS_NAME="prod"

if [ -z "$BOT_ID" ]; then
  echo "❌ Você precisa informar o botId como argumento."
  echo "🧪 Exemplo de uso: ./deploy-bot.sh abcdefghijklmnop123456"
  exit 1
fi

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