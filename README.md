# AWS Bootstrap Env Script

Script para instalar dependências e injetar variáveis de ambiente a partir do AWS Secrets Manager.

O que o script faz:
    * Instalação de unzip, jq e AWS CLI (v2)
    * Download de secrets do AWS Secrets Manager
    * Geração de arquivo .env no diretório especificado

# Como usar no user-data da EC2:

```bash
#!/bin/bash
curl -fsSL https://raw.githubusercontent.com/veezor/secrets-to-ec2/main/setup.sh | bash -s /opt/myapp staging/my-secrets us-east-1
```
# Parâmetros
    APP_DIR — Caminho onde será salvo o .env (default: /opt/myapp)
    SECRET_ID — Nome do segredo no AWS Secrets Manager (default: staging/my-secrets)
    REGION — Região da AWS (default: us-east-1)

# Requisitos
    EC2 com role/permissão para acessar o Secrets Manager
    Ubuntu/Debian-based por enquanto
