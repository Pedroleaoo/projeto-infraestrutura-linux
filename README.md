# Projeto Prático Integrador: Infraestrutura de Redes e Servidores Linux

Repositório oficial para documentação e automação da infraestrutura de TI simulada em ambiente virtualizado (Oracle VirtualBox) para uma startup em expansão.

## Topologia e Zonas de Segurança
A infraestrutura está segmentada em três zonas distintas de segurança:
* **DMZ (10.0.1.0/24):** Abriga o Servidor Web (Nginx + Aplicação).
* **LAN (10.0.2.0/24):** Abriga a rede corporativa, estações de trabalho (CLIENT) e o Servidor de Arquivos (FILES - Samba).
* **DB Zone (10.0.3.0/24):** Zona isolada contendo o Servidor de Banco de Dados (DB - PostgreSQL 16+), sem acesso direto pela Internet.
