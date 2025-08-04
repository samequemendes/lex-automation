import boto3
import time
import requests

SOURCE_PROFILE = "AdministratorAccess-743065069150"
BOT_ID = "WMZQH0M4SQ"
BOT_VERSION = "DRAFT"
REGION = "us-east-1"

# Cria uma sessão com o profile especificado
session = boto3.Session(profile_name=SOURCE_PROFILE, region_name=REGION)
client = session.client('lexv2-models')

# Inicia o export
response = client.create_export(
    resourceSpecification={
        'botExportSpecification': {
            'botId': BOT_ID,
            'botVersion': BOT_VERSION
        }
    },
    fileFormat='LexJson'
)
export_id = response['exportId']

# Aguarda o export ser concluído
while True:
    desc = client.describe_export(exportId=export_id)
    status = desc['exportStatus']
    print(f"Status: {status}")
    if status == "Completed":
        break
    if status == "Failed":
        print("❌ Exportação falhou.")
        exit(1)
    time.sleep(5)

# Faz o download do arquivo exportado
download_url = desc['downloadUrl']
r = requests.get(download_url)
with open("bot-export-py.zip", "wb") as f:
    f.write(r.content)
print("✅ Exportação concluída e arquivo salvo como bot-export-py.zip")