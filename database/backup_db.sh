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

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/db_backup_$TIMESTAMP.sql"

echo "[*] A iniciar o backup da base de dados $DB_NAME..."
mkdir -p "$BACKUP_DIR"

# Executar pg_dump para gerar o dump da base de dados com segurança
pg_dump -U "$DB_USER" -d "$DB_NAME" -F c -b -v -f "$BACKUP_FILE"
echo "[+] Backup concluído com sucesso em $BACKUP_FILE"
