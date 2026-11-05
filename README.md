# Infraestrutura de Redes e Servidores Linux

Projeto prático de infraestrutura para um laboratório corporativo virtualizado no Oracle VirtualBox. O repositório reúne configurações e um script Bash para demonstrar segmentação de rede, serviços básicos de infraestrutura e compartilhamento de arquivos; os arquivos são modelos para aplicação nas VMs, não imagens de máquinas virtuais nem uma aplicação web completa.

> **Atenção:** as configurações pressupõem nomes de interfaces, endereços e serviços específicos. Revise-os para o seu ambiente antes de aplicá-los. A execução do provisionamento altera configurações do sistema e reinicia serviços; faça testes em VMs descartáveis e mantenha acesso ao console.

## Equipa desenvolvedora

- Pedro Vítor Leão de Oliveira
- Bruno Silva Sena
- Gabriel Dantas Leal
- Matheus Gabriel Silva de Andrade
- Francisco César Agapito Llarena
- Abraão Henrique Franco de Araújo

## Objetivo e topologia

O laboratório separa os serviços por segmentos de rede ligados a um firewall/roteador Linux:

| Zona | Rede | Endereço/uso documentado |
| --- | --- | --- |
| WAN | DHCP na interface `enp0s3` | Conexão externa da VM de firewall |
| DMZ | `10.0.1.0/24` | Interface do firewall: `10.0.1.1`; destinada ao servidor web na arquitetura proposta |
| LAN | `10.0.2.0/24` | Gateway `10.0.2.1`; clientes e servidor de arquivos |
| Banco de dados | `10.0.3.0/24` | Gateway `10.0.3.1`; PostgreSQL escuta em `10.0.3.10` |

A configuração do cliente registra o endereço `10.0.2.101/24`. O `dnsmasq` distribui endereços de `10.0.2.100` a `10.0.2.200`, anuncia `10.0.2.1` como gateway e DNS, e reserva `10.0.2.10` para o MAC configurado para `files`. O domínio local é `empresa.local`.

### Máquinas e serviços previstos

- **FW:** roteamento entre WAN, DMZ, LAN e rede do banco; configurações Netplan, `iptables` e `dnsmasq`.
- **WEB:** Nginx servindo conteúdo estático a partir de `/var/www/html`, com o nome `web.empresa.local`.
- **FILES:** Samba com partilhas públicas, de projetos e de backups.
- **DB:** PostgreSQL com endereço de escuta e regra de autenticação para a aplicação.
- **CLIENT:** estação de teste na LAN.

## Organização do repositório

```text
.
├── client/
│   └── network-info.txt       # Endereço e finalidade da estação cliente
├── database/
│   ├── backup_db.sh           # Dump PostgreSQL em formato customizado
│   ├── pg_hba.conf            # Regras de autenticação de clientes
│   └── postgresql.conf        # Endereço de escuta do PostgreSQL
├── docs/
│   └── pendencias.md          # Arquivo de pendências ainda vazio
├── files/
│   └── samba/smb.conf         # Definição das partilhas Samba
├── firewall/
│   ├── dnsmasq/lab.conf       # DHCP, DNS local e encaminhamento DNS
│   ├── netplan/01-lab.yaml    # Interfaces e endereços do firewall
│   └── iptables.rules         # Regras de filtro IPv4
├── scripts/
│   └── provision.sh           # Instala pacotes e copia algumas configurações
└── web/
    └── nginx/default          # Virtual host HTTP padrão do Nginx
```

## Como as configurações se relacionam

`firewall/netplan/01-lab.yaml` define quatro interfaces na VM de firewall. O `dnsmasq` atende a LAN pela `enp0s9`, distribui DHCP e resolve nomes locais; o arquivo `firewall/iptables.rules` contém regras de filtro para tráfego destinado ao próprio firewall. As configurações de Samba, Nginx e PostgreSQL devem ser instaladas nos servidores correspondentes. O cliente serve como ponto de verificação de conectividade.

O script `scripts/provision.sh` instala `netplan.io`, `dnsmasq`, `samba`, `postgresql`, `nginx` e `python3`, e copia configurações de Netplan, `dnsmasq`, Samba e Nginx se os respectivos arquivos existirem no diretório de trabalho. **Ele não configura as regras de `iptables`, nem aplica `database/postgresql.conf`, `database/pg_hba.conf` ou o agendamento do backup.** Como copia configurações de vários serviços para o sistema em que é executado, não é um instalador que separa ou detecta automaticamente as VMs: adapte-o e execute-o apenas no host de laboratório apropriado.

## Pré-requisitos

- VMs Linux baseadas em Debian/Ubuntu, com `apt-get`, `sudo` e Bash.
- Oracle VirtualBox configurado com interfaces e redes correspondentes à topologia.
- Nomes de interfaces compatíveis com os arquivos (por exemplo, `enp0s3`, `enp0s8`, `enp0s9` e `enp0s10`) ou configurações ajustadas para os nomes reais.
- Acesso administrativo às VMs. O provisionamento requer conexão com os repositórios de pacotes para executar `apt-get update`.

## Provisionamento

A partir da raiz do repositório, na VM de laboratório que receberá a configuração:

```bash
chmod +x scripts/provision.sh
./scripts/provision.sh
```

O script usa `sudo` para instalar pacotes, copiar arquivos para `/etc` e reiniciar serviços. Leia e adapte os arquivos antes da execução; uma configuração de rede incompatível pode interromper a conectividade da VM.

### Aplicação manual das configurações de banco e firewall

Esses arquivos não são instalados pelo script de provisionamento. Em suas respectivas VMs, revise os caminhos e aplique-os conforme a versão do sistema e a instalação dos serviços. Para a rotina de backup, o script procura `/opt/scripts/.env` com as variáveis `DB_USER`, `DB_NAME` e `BACKUP_DIR`; o arquivo não deve ser versionado. Por exemplo, a tarefa de agendamento com `cron` deve ser configurada separadamente, pois o repositório não contém uma instalação automática dela.

## Serviços configurados e limitações atuais

- **Nginx:** o virtual host fornecido escuta na porta HTTP 80 e tenta servir arquivos estáticos. Não configura proxy reverso, HTTPS/TLS, certificado ou rate limiting.
- **Firewall:** `iptables.rules` define `INPUT` como `DROP`, mas `FORWARD` como `ACCEPT`. O arquivo inclui liberações de loopback, conexões estabelecidas e portas DNS/DHCP; não implementa por si só uma política completa de filtragem entre zonas nem as regras de NAT descritas na arquitetura pretendida. Valide o encaminhamento e a política de segurança antes de conectar as VMs a redes externas.
- **Samba:** a partilha `publico` permite acesso convidado com escrita. `projetos` restringe usuários aos grupos `@devs` e `@diretoria`; `backups` restringe ao grupo `@backup_mgr`. Os diretórios e grupos do sistema precisam existir e ter permissões adequadas.
- **PostgreSQL:** `postgresql.conf` limita a escuta a `10.0.3.10`. `pg_hba.conf` permite a `empresa_db`/`app_user` conectar a partir de `10.0.2.0/24` usando `scram-sha-256`; banco, usuário, senha e serviço precisam ser preparados separadamente.
- **Backup:** `database/backup_db.sh` executa `pg_dump` e grava um dump customizado no diretório indicado por `BACKUP_DIR`. Sem as variáveis válidas no arquivo de ambiente, o backup não está pronto para execução.

A topologia e a descrição de arquitetura representam a intenção do laboratório; consulte as configurações concretas acima, pois nem todos os recursos descritos estão implementados nos arquivos atuais. Não há suíte de testes automatizada ou processo de build no repositório.

## Segurança e uso em laboratório

Use redes isoladas do VirtualBox durante a validação. Revise regras de firewall, credenciais, endereços MAC, interfaces, permissões das partilhas e escuta do PostgreSQL antes de qualquer implantação. Evite expor a partilha Samba convidada ou serviços do laboratório a redes não confiáveis. Arquivos `.env`, chaves privadas e certificados privados não devem ser adicionados ao Git; o `.gitignore` já exclui `.env`, `*.key` e `*.pem`.
