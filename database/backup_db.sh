#!/usr/bin/env bash
# ==============================================================================
# Script de Backup da Base de Dados PostgreSQL
# ==============================================================================
set -Eeuo pipefail

# Carregar variáveis de ambiente externas de forma segura
if [ -f "/opt/scripts/.env" ]; then
    source /opt/scripts/.env
else
    # Valores predefinidos para laboratório caso o .env não exista
    DB_USER=""
    DB_NAME=""
    BACKUP_DIR=""
fi

TIMESTAMP=
BACKUP_FILE="/db_backup_.sql"

echo "[*] A iniciar o backup da base de dados ..."
mkdir -p ""

# Executar pg_dump para gerar o dump da base de dados com segurança
pg_dump -U "" -d "" -F c -b -v -f ""
echo "[+] Backup concluído com sucesso em "
