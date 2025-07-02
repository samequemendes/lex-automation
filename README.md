# Amazon Lex Bot - Exportação e Importação

Scripts e playbook para exportar um bot do Amazon Lex V2 de uma conta e importar em outra.

## Conteúdo

- `scripts/export-bot.sh`: Exporta bot e baixa o arquivo `.zip`
- `scripts/import-bot.sh`: Importa bot usando o `.zip`
- `playbook.yml`: Executa ambos com Ansible
- `README.md`: Documentação do processo
- `historico.txt`: Resumo desta conversa para referência

## Pré-requisitos

- AWS CLI configurado com perfis para origem e destino
- jq instalado
- Permissões adequadas para Lex e IAM roles

## Execução com Ansible

```bash
ansible-playbook playbook.yml
```

## A cada nova alteração de intents, você precisa:

- Atualizar o locale
- Criar uma nova versão
- Atualizar o alias, se quiser apontar para a nova versão