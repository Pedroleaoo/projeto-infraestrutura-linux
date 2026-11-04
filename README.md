# 🐧 Projeto Prático: Infraestrutura de Redes e Servidores Linux

Repositório oficial para a documentação, configuração e automação de uma infraestrutura de TI corporativa simulada em ambiente virtualizado (Oracle VirtualBox), desenvolvida para atender aos requisitos de segurança, segmentação de rede e alta disponibilidade de uma startup em expansão.

---

## 👥 Equipa Desenvolvedora

* Pedro Vítor Leão de Oliveira
* Bruno Silva Sena
* Gabriel Dantas Leal
* Matheus Gabriel Silva de Andrade
* Francisco César Agapito Llarena
* Abraão Henrique Franco de Araújo

---

## 📐 Topologia e Zonas de Segurança

A rede foi cuidadosamente segmentada através de um firewall de borda para isolar os serviços críticos e proteger os dados sensíveis:

1. **DMZ (Zona Desmilitarizada) — `10.0.1.0/24`**
   * Contém o **Servidor Web (WEB)** com Nginx atuando como proxy reverso, terminação SSL/TLS e rate limiting.
2. **LAN (Rede Local / Corporativa) — `10.0.2.0/24`**
   * Abriga os utilizadores/estações de trabalho (`CLIENT`) e o **Servidor de Arquivos (FILES)** com partilhas controladas via Samba.
3. **DB Zone (Zona de Base de Dados) — `10.0.3.0/24`**
   * Zona altamente restrita contendo o **Servidor de Banco de Dados (DB)**, isolada do acesso externo direto e acessível apenas a partir da DMZ.

---

## 🖥️ Arquitetura das Máquinas Virtuais (VMs)

| Máquina | Função Principal | Tecnologias / Configurações Principais |
| :--- | :--- | :--- |
| **FW** | Firewall de Borda & Roteamento | Netplan (interfaces múltiplas), Regras estáticas de `iptables` (INPUT/FORWARD DROP), NAT. |
| **FILES** | Servidor de Arquivos | Samba (`smb.conf`), partilhas públicas, de projetos (`@devs`, `@diretoria`) e backups (`@backup_mgr`). |
| **WEB** | Servidor Web & Proxy Reverso | Nginx, Certificados SSL/TLS autoassinados, Redirecionamento HTTP $\rightarrow$ HTTPS, Rate Limiting (`limit_req`). |
| **DB** | Banco de Dados Relacional | PostgreSQL 16, restrição de escuta (`listen_addresses`), autenticação `scram-sha-256` via `pg_hba.conf`, Script de backup automatizado via Cron. |
| **CLIENT** | Estação de Trabalho / Testes | IP dinâmico/estático na LAN (`10.0.2.101/24`), validação de conectividade. |

---

## 📁 Estrutura do Repositório

```text
projeto-infraestrutura-linux/
├── README.md                 # Documentação central do projeto
├── .gitignore                # Exclusão de segredos, logs e ficheiros temporários
├── firewall/
│   ├── netplan/
│   │   └── 01-lab.yaml       # Configuração de redes e interfaces do Firewall
│   └── iptables.rules        # Regras persistentes de filtragem e encaminhamento
├── fileserver/
│   └── smb.conf              # Configuração das partilhas e segurança do Samba
├── web/
│   └── nginx/
│       └── default           # Configuração de hosts virtuais, SSL e proxy reverso do Nginx
├── database/
│   ├── pg_hba.conf           # Controlo de acesso e autenticação do PostgreSQL
│   ├── postgresql.conf       # Ajustes de escuta e rede do PostgreSQL
│   ├── backup_db.sh          # Script automatizado de dump, compactação e envio via CIFS
├── client/
│   └── network-info.txt      # Documentação de rede da máquina cliente
└── docs/
    └── pendencias.md         # Registo de itens futuros (DNS/DHCP, código de aplicação)
