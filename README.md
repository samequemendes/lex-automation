
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

```bash
ansible-playbook playbook-deploy.yml --tag deploy
ansible-playbook playbook-migration.yml --tag export
ansible-playbook playbook-deploy.yml --tag destroy
ansible-playbook playbook-deploy.yml --tag auth,pos_import -e bot_id="1KEHBD9NI8" -e alias_name="teste-alias-v0" -vvv
```

## A cada nova alteração de intents, você precisa:

- Atualizar o locale
- Criar uma nova versão
- Atualizar o alias, se quiser apontar para a nova versão

Possível através do script `pos-import-bot.sh`