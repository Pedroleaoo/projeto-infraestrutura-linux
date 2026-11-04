#!/usr/bin/env bash
# ==============================================================================
# Script de Provisionamento e Configuração do Laboratório de Infraestrutura
# Foco: Firewall (Netplan/Dnsmasq) e Servidor de Arquivos (Samba)
# ==============================================================================

set -Eeuo pipefail

echo "[+] A iniciar o provisionamento do ambiente..."

# 1. Configuração de Redes e Netplan (Firewall)
if [ -d "firewall/netplan" ]; then
    echo "[*] A aplicar configurações do Netplan..."
    sudo cp firewall/netplan/01-lab.yaml /etc/netplan/01-lab.yaml
    sudo netplan apply
fi

# 2. Configuração do Dnsmasq (DNS/DHCP)
if [ -f "firewall/dnsmasq/lab.conf" ]; then
    echo "[*] A configurar o Dnsmasq..."
    sudo cp firewall/dnsmasq/lab.conf /etc/dnsmasq.d/lab.conf
    sudo systemctl restart dnsmasq
fi

# 3. Configuração do Servidor de Arquivos (Samba e Estruturas de Pastas)
if [ -f "files/samba/smb.conf" ]; then
    echo "[*] A configurar o Samba e diretórios compartilhados..."
    sudo cp files/samba/smb.conf /etc/samba/smb.conf
    
    # Criar diretórios reais mapeados no laboratório
    sudo mkdir -p /compartilhado/publico
    sudo mkdir -p /compartilhado/projetos
    sudo mkdir -p /compartilhado/backups

    # Definir permissões de segurança por grupos
    sudo chmod 777 /compartilhado/publico
    sudo chown -R root:devs /compartilhado/projetos
    sudo chmod 770 /compartilhado/projetos
    sudo chown -R root:backup_mgr /compartilhado/backups
    sudo chmod 770 /compartilhado/backups

    sudo systemctl restart smbd
fi

echo "[+] Provisionamento concluído com sucesso!"
