
# Lex Automation

Este projeto automatiza o processo de exportação, importação e implantação de bots no Amazon Lex, utilizando Ansible, Bash Scripts e Terraform.

## 📦 Estrutura do Projeto

```
lex-automation-main/
├── .ansible/                 # Lock de execução Ansible
├── scripts/                 # Scripts Bash auxiliares para listagem e pós-importação de bots
├── tasks/                   # Papéis Ansible organizados por função (auth, checkout, terraform, etc)
├── templates/               # Templates Jinja2 para arquivos Terraform
├── vars/                    # Variáveis Ansible
├── playbook-deploy.yml      # Playbook principal para deploy do bot
├── playbook-migration.yml   # Playbook para migração de bots entre ambientes
├── .gitignore
```

## 🚀 Requisitos

- Python 3.x
- Ansible
- AWS CLI configurado
- Terraform (instalado na máquina)
- Permissões válidas na AWS (IAM)

## ⚙️ Executando os Playbooks

### Deploy do Bot

```bash
ansible-playbook playbook-deploy.yml -i localhost
```

### Migração de Bots (Exporta e importa entre contas ou regiões)

```bash
ansible-playbook playbook-migration.yml -i localhost
```

## 📜 Scripts Auxiliares

- `scripts/list-bots.sh`: Lista os bots existentes no Lex.
- `scripts/pos-import-bot.sh`: Etapas pós-importação (versão inicial).
- `scripts/pos-import-bot-v2.sh`: Etapas pós-importação (versão atualizada).

## 🔐 Variáveis Sensíveis

Configure suas credenciais AWS via `aws configure` ou exporte diretamente no terminal:

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
```

## 📄 Personalização

- Variáveis personalizáveis estão em `vars/config.yml`.
- Templates Terraform estão em `templates/` e podem ser ajustados conforme a necessidade da sua infraestrutura.

## ✅ Boas Práticas

- Recomendado utilizar um ambiente virtual Python.
- Validar previamente permissões das roles utilizadas.
- Os playbooks são compatíveis com execução local (`-i localhost`).

## 📁 Licença

Este projeto é distribuído sob a licença MIT.

## Execução com Ansible
### Deploy Bot

```bash
ansible-playbook playbook-deploy.yml --tag deploy -e bot_name="nome-do-bot"
ansible-playbook playbook-deploy.yml --tag destroy -e bot_name="nome-do-bot"

ansible-playbook playbook-migration.yml --tag export -e bot_id="1KEHBD9NI8" -e bot_version="DRAFT" -e orig_account_id="022499044898" -e dest_account_id="743065069150"
```

### Exportação Bot

```bash
ansible-playbook playbook-migration.yml --tag export -e bot_id="1KEHBD9NI8" -e bot_version="DRAFT" -e orig_account_id="022499044898" -e dest_account_id="743065069150"
```


## A cada nova alteração de intents, você precisa:

- Atualizar o locale
- Criar uma nova versão
- Atualizar o alias, se quiser apontar para a nova versão

Possível através do script `pos-import-bot.sh`

# 📘 Variáveis do Projeto de Migração Amazon Lex V2

Este documento descreve as variáveis utilizadas no projeto de automação para exportação e importação de bots do Amazon Lex V2 com Ansible.

---

## 📌 Identificação dos bots
- **`bot_id`**  
  ID do bot na conta origem (UUID fornecido pelo Lex).  
  Exemplo: `1KEHBD9NI8`.

- **`bot_version`**  
  Versão do bot a exportar (`DRAFT` ou número de versão publicado).  
  Exemplo: `DRAFT`.

- **`bot_import_name`**  
  Nome que o bot receberá na conta destino após a importação.  
  Exemplo: `Bot-automatizado-importado`.

- **`bot_export_path`**  
  Caminho local do arquivo `.zip` exportado pelo Lex.  
  Exemplo: `artifacts/{{ ansible_date_time.date }}-{{ bot_id }}.zip`.

---

## 📌 Contas e IAM
- **`orig_account_id`**  
  ID da conta **origem**.  
  Exemplo: `022499044898`.

- **`dest_account_id`**  
  ID da conta **destino**.  
  Exemplo: `743065069150`.

- **`prefix_iam`**  
  Prefixo fixo para construir ARNs de roles IAM.  
  Valor padrão: `arn:aws:iam::`.

- **`role_name`**  
  Nome da role cross-account utilizada para assumir permissões.  
  Exemplo: `:role/CrossAccountMasterRole`.

- **`dest_account`**  
  Montagem final do ARN da role na conta destino.  
  Construído assim:  
  ```yaml
  dest_account: "{{ prefix_iam + dest_account_id + role_name }}"
  ```  
  Exemplo: `arn:aws:iam::743065069150:role/CrossAccountMasterRole`.

- **`role_arn`**  
  Role de execução que o **Lex** assume na conta destino (para logs, Lambda, etc.).  
  Exemplo: `arn:aws:iam::743065069150:role/poc-role-amazon-lex-sameque-mendes`.

---

## 📌 Região
- **`region`**  
  Região AWS onde o bot está provisionado.  
  Exemplo: `us-east-1`.

---

## 📌 Credenciais temporárias
Essas variáveis são preenchidas automaticamente após o `sts_assume_role`:

- **`aws_access_key`**  
- **`aws_secret_key`**  
- **`aws_session_token`**  

> ⚠️ **Importante**: nunca exponha esses valores em logs (`no_log: true` recomendado).

---
