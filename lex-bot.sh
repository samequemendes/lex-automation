#!/bin/bash

set -e

PROJECT_NAME="ansible-project"

mkdir -p $PROJECT_NAME/{inventory,playbooks,roles/common/{defaults,files,handlers,meta,tasks,templates,vars},scripts}

# Criar arquivos vazios essenciais
touch $PROJECT_NAME/README.md
touch $PROJECT_NAME/inventory/hosts.yml
touch $PROJECT_NAME/playbooks/main.yml
touch $PROJECT_NAME/roles/common/defaults/main.yml
touch $PROJECT_NAME/roles/common/handlers/main.yml
touch $PROJECT_NAME/roles/common/meta/main.yml
touch $PROJECT_NAME/roles/common/tasks/main.yml
touch $PROJECT_NAME/roles/common/vars/main.yml
touch $PROJECT_NAME/scripts/bootstrap.sh

# Mensagem final
echo "Estrutura criada com sucesso em: $PROJECT_NAME/"

