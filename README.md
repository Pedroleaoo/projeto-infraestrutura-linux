# Projeto de Infraestrutura de Redes e Serviços Linux

Repositório oficial para a gestão, documentação e provisionamento da infraestrutura de laboratório baseada em Linux (Ubuntu).

## 📁 Estrutura do Repositório
- **firewall/**: Configurações de rede Netplan, regras de iptables e Dnsmasq (DNS/DHCP).
- **files/**: Configuração do Servidor de Arquivos Samba com partições restritas por grupos.
- **database/**: Configuração do PostgreSQL (pg_hba.conf) e rotinas de backup (ackup_db.sh).
- **web/**: Configurações do servidor web Nginx.
- **app/**: Código da aplicação (pp.py).
- **scripts/**: Script automatizado (provision.sh) para o provisionamento completo dos serviços.

## ⚙️ Provisionamento
O script scripts/provision.sh instala e configura automaticamente todos os serviços necessários nas máquinas virtuais do laboratório.
