#!/bin/bash
set -e

echo ">>> Iniciando injeção de secrets <<<"
# Variáveis com valores padrão, substituíveis por argumentos
APP_DIR="${1:-/opt/myapp}"
SECRET_ID="${2:-staging/my-secrets}"
REGION="${3:-us-east-1}"

# Cria o diretório da aplicação, se não existir
echo ">>> Cria $APP_DIR se ainda não existe."
mkdir -p "$APP_DIR"
ls -lsa $APP_DIR

apt update -y
# Instala unzip se não estiverem instalados
echo ">>> Unzip"
if ! command -v unzip >/dev/null 2>&1; then
  apt install -y unzip jq
fi

# Instala jq se não estiverem instalados
echo ">>> jq"
if ! command -v jq >/dev/null 2>&1; then
  apt install -y jq
fi

# Instala AWS CLI v2 se não estiver instalada
echo ">>> aws"
aws --version
if ! command -v aws >/dev/null 2>&1; then
  cd /tmp
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -q awscliv2.zip
  ./aws/install
  cd -
fi

# Recupera o segredo do AWS Secrets Manager
echo ">>> Recebe os secrets"
SECRET_JSON=$(aws secretsmanager get-secret-value \
  --region "$REGION" \
  --secret-id "$SECRET_ID" \
  --query SecretString \
  --output text)
echo $SECRET_JSON

# Exporta como arquivo .env no diretório da aplicação
echo "$SECRET_JSON" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"' > "$APP_DIR/.env"
ls -lsa $APP_DIR

APP_OWNER=$(stat -c '%U' "$APP_DIR")
chown "$APP_OWNER:$APP_OWNER" "$APP_DIR/.env"
chmod 600 "$APP_DIR/.env"

echo "$SECRET_JSON" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"' > "$APP_DIR/.env2"

APP_OWNER=$(stat -c '%U' "$APP_DIR")
chown "$APP_OWNER:$APP_OWNER" "$APP_DIR/.env2"
chmod 600 "$APP_DIR/.env2"

ls -lsa $APP_DIR
echo ">>> [OK] .env gerado em $APP_DIR com variáveis de ambiente"
