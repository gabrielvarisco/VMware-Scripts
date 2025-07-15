
# 🛡️ VMware Hardening Guide

Este repositório centraliza práticas recomendadas de hardening para ambientes VMware ESXi e vCenter, com foco em segurança sem custo adicional e aplicável a ambientes corporativos de pequeno a grande porte.

⚙️ **Importante**: As configurações descritas aqui devem ser **padronizadas via Host Profile** (Vide item 5) sempre que possível, garantindo conformidade entre hosts, facilidade de auditoria e agilidade na remediação.

---

## ✅ Pré-requisitos

- Hosts VMware ESXi com vCenter Server para gerenciamento centralizado  
- Acesso ao **vSphere Client (HTML5)** com permissões administrativas

---

## 🔎 Índice

1. [Lockdown Mode (Strict)](#1-🔒-habilitar-lockdown-mode-modo-estrito)
2. [Firewall do ESXi](#2-🔥-configuração-do-firewall-do-esxi)
3. [Traffic Filtering and Marking](#3-🧱-ativar-e-configurar-traffic-filtering-and-marking)
4. [Firewall no vCenter Server](#4-🧱-configuração-do-firewall-no-vcenter-server)
5. [Host Profile](#5-🧩-aplicar-configurações-via-host-profile)
6. [Desabilitar SSH e ESXi Shell](#6-🚫-desabilitar-esxi-shell-e-ssh-quando-não-estiverem-em-uso)
7. [Desabilitar serviços desnecessários](#7-⚙️-desabilitar-serviços-desnecessários-no-esxi)
8. [Configurar syslog remoto](#8-📝-configurar-syslog-remoto-no-esxi)
9. [Aplicar RBAC no vCenter](#9-👥-aplicar-rbac-corretamente-no-vcenter)
10. [Remover contas locais genéricas](#10-👤-remover-contas-locais-genéricas-ou-não-rastreáveis)
11. [Habilitar login banner](#11-📢-habilitar-login-banner-aviso-legal)
12. [Substituir certificados autoassinados](#12-🔐-substituir-certificados-autoassinados-por-certificados-válidos)
13. [Isolamento de redes técnicas](#13-🌐-isolamento-de-rede-de-gerenciamento-vmotion-vsan-entre-outras)
14. [Auditoria e Logs](#14-🚨-auditoria-e-logs)
15. [Atualizações de Segurança e Patches](#15-⚡-atualizações-de-segurança-e-patches)

---

1. 🔒 Habilitar Lockdown Mode (Modo Estrito)
O Lockdown Mode limita os métodos de administração do host ESXi, forçando a administração a ser feita exclusivamente via vCenter.

Modos Disponíveis:
Modo	Acesso SSH	Acesso DCUI (Console Físico)	Exceções via "Exception Users"
Normal	Negado	Permitido	Permitido
Strict	Negado	Negado	Permitido

Recomendado:
Ativar o Lockdown Mode em Modo Estrito

Criar um usuário técnico de exceção com permissões mínimas (ex: svc-esxi-access)

Adicionar esse usuário à lista de Exception Users no host

Desativar o serviço DCUI para impedir acesso físico, mesmo via console remoto (iDRAC/iLO)

Essas configurações podem ser aplicadas e padronizadas via Host Profile para todos os hosts do cluster

Caminho para Ativar Lockdown Mode:
pgsql
Copiar
vSphere Client > Host > Configure > System > Security Profile > Edit > Enable Lockdown Mode (Strict)
Sobre DCUI e Interfaces de Gerenciamento Remoto (iDRAC, iLO)
Mesmo com o Lockdown Mode ativado, o acesso físico ou virtual ao console via iDRAC, iLO ou IPMI ainda permite o acesso ao DCUI (Direct Console User Interface).

⚠️ Para que o modo Strict seja verdadeiramente seguro, é necessário desativar manualmente o DCUI.

Desativar DCUI (via vSphere Client):
arduino
Copiar
vSphere Client > Host > Configure > System > Services > Direct Console UI > Stop
Em seguida, clique em "Policy" e selecione:  
Start and stop manually
Desativar DCUI (via Shell):
swift
Copiar
esxcli system settings advanced set -o /UserVars/ESXiShellTimeOut -i 0
esxcli system settings advanced set -o /UserVars/DCUI -i 0
/etc/init.d/DCUI stop
🛠️ Se for necessário reativar o DCUI:

Via vSphere Client:

arduino
Copiar
vSphere Client > Host > Configure > System > Services > Direct Console UI > Start
Via Shell/SSH:

swift
Copiar
/etc/init.d/DCUI start
🧠 Recomendações Adicionais:

Aplique controle de acesso com senha forte e 2FA na iDRAC/iLO

Audite periodicamente o uso do console remoto com ferramentas como Graylog, Aria Operations for Logs ou outro SIEM integrado

Monitore eventos de ativação do DCUI e alterações no Lockdown Mode


2. 🔥 Configuração do Firewall do ESXi
Configure o firewall local de cada host ESXi para permitir apenas IPs confiáveis nos seguintes serviços:

Serviço	Porta padrão	Ação recomendada
vSphere Web Access	443	Permitir apenas IPs de administração
vSphere Web Client	902	Restringir a hosts do vCenter
SSH Server	22	Permitir apenas para bastion/jump box

Caminho:
arduino
Copiar
vSphere Client > Host > Configure > System > Firewall > Edit > Allowed IP Addresses
⚠️ Importante: Caso a lista de IPs permitidos para um serviço esteja vazia, ele ficará acessível para qualquer origem. Preencha sempre explicitamente os IPs autorizados para cada serviço crítico.


3. 🧱 Ativar e Configurar Filtragem de Tráfego
Utilize filtros de tráfego para isolar e proteger a comunicação entre VMs e hosts.

Exemplo de Caso Prático:
Criar um Jump Server com IP fixo (ex: 192.168.100.10)

Permitir RDP e SSH somente deste IP

Bloquear todo o restante com regras de Traffic Filtering

Recomendado:
Integrar o Jump Server com RADIUS + MFA

Utilizar RDP Gateway com autenticação de dois fatores

Caminho:
arduino
Copiar
vSphere Client > Networking > Distributed Port Group > Configure > Traffic Filtering and Marking
🔐 Isso ajuda a evitar acesso lateral não autorizado dentro da rede virtualizada.

