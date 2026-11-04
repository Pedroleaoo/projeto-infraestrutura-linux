#!/usr/bin/env bash
# ==============================================================================
# Script de Provisionamento Completo do Ambiente de Infraestrutura
# ==============================================================================
set -Eeuo pipefail

echo "[+] A iniciar o provisionamento completo dos serviços nas VMs..."

# 1. Instalação e atualização dos pacotes essenciais
sudo apt-get update
sudo apt-get install -y netplan.io dnsmasq samba postgresql nginx python3

# 2. Aplicar configurações de rede (Netplan)
if [ -f "firewall/netplan/01-lab.yaml" ]; then
    sudo cp firewall/netplan/01-lab.yaml /etc/netplan/01-lab.yaml
    sudo netplan apply
fi

# 3. Configurar Dnsmasq
if [ -f "firewall/dnsmasq/lab.conf" ]; then
    sudo cp firewall/dnsmasq/lab.conf /etc/dnsmasq.d/lab.conf
    sudo systemctl restart dnsmasq
fi

# 4. Configurar Samba
if [ -f "files/samba/smb.conf" ]; then
    sudo cp files/samba/smb.conf /etc/samba/smb.conf
    sudo systemctl restart smbd
fi

# 5. Configurar Nginx
if [ -f "web/nginx/default" ]; then
    sudo cp web/nginx/default /etc/nginx/sites-available/default
    sudo systemctl restart nginx
fi

echo "[+] Provisionamento concluído com 100% de sucesso!"
