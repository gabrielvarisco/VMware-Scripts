
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

## 🔐 Hardening de VMware ESXi e vCenter

### 1. 🔒 Habilitar **Lockdown Mode** (modo estrito)

O **Lockdown Mode** limita os métodos pelos quais o host ESXi pode ser administrado diretamente, forçando a administração a ser feita exclusivamente via **vCenter**.

#### Modos disponíveis:

| Modo     | Acesso SSH | Acesso DCUI (console físico) | Exceções via "Exception Users" |
|----------|------------|------------------------------|--------------------------------|
| Normal   | Negado     | Permitido                    | Permitido                      |
| Strict   | Negado     | **Negado**                   | Permitido                      |

#### **Recomendado:**
- Ativar o Lockdown Mode em **modo Strict**
- Criar um usuário técnico de exceção com permissões mínimas (ex: `svc-esxi-access`)
- Adicionar esse usuário à lista de **Exception Users** no host
- **Desativar o serviço DCUI** para impedir acesso físico mesmo via console remoto (iDRAC/iLO)
- **Essas configurações podem ser aplicadas e padronizadas via Host Profile para todos os hosts do cluster**

#### **Caminho para ativar Lockdown Mode:**
```
vSphere Client > Host > Configure > System > Security Profile > Edit > Enable Lockdown Mode (Strict)
```

#### **Sobre DCUI e interfaces de gerenciamento remoto (iDRAC, iLO)**

Mesmo com o Lockdown Mode ativado, o acesso **físico ou virtual** ao console via iDRAC, iLO ou IPMI ainda permite acesso ao **DCUI (Direct Console User Interface)**, que é executado diretamente no host.

⚠️ Para que o modo **Strict** seja verdadeiramente seguro, é necessário **desativar manualmente o DCUI**.

#### **Desativar DCUI (via vSphere Client):**
```
vSphere Client > Host > Configure > System > Services > Direct Console UI > Stop
Em seguida, clique em "Policy" e selecione:  
Start and stop manually
```

#### **Desativar DCUI (via shell):**
```
esxcli system settings advanced set -o /UserVars/ESXiShellTimeOut -i 0
esxcli system settings advanced set -o /UserVars/DCUI -i 0
/etc/init.d/DCUI stop
```

🛠️ **Se for necessário reativar o DCUI:**

**Via vSphere Client:**
```
vSphere Client > Host > Configure > System > Services > Direct Console UI > Start
```

**Via shell/SSH:**
```
/etc/init.d/DCUI start
```

🧠 **Recomendações adicionais:**
- Aplique controle de acesso com senha forte e 2FA na iDRAC/iLO  
- Audite periodicamente o uso do console remoto com ferramentas como **Graylog**, **Aria Operations for Logs** ou outro SIEM integrado  
- Monitore eventos de ativação do DCUI e alterações no Lockdown Mode

### 2. 🔥 Configuração do **Firewall do ESXi**

Configure o firewall local de cada host ESXi para permitir apenas IPs confiáveis nos seguintes serviços:

| Serviço               | Porta padrão | Ação recomendada                      |
|-----------------------|--------------|---------------------------------------|
| vSphere Web Access    | 443          | Permitir apenas IPs de administração  |
| vSphere Web Client    | 902          | Restringir a hosts do vCenter         |
| SSH Server            | 22           | Permitir apenas para bastion/jump box |

#### Caminho:
```
vSphere Client > Host > Configure > System > Firewall > Edit > Allowed IP Addresses
```

⚠️ Importante: caso a lista de IPs permitidos para um serviço esteja vazia, ele ficará acessível para qualquer origem. Preencha sempre explicitamente os IPs autorizados para cada serviço crítico.

### 3. 🧱 Ativar e configurar **Traffic Filtering and Marking**

Use filtros de tráfego para isolar e proteger a comunicação entre VMs e hosts. Uma boa prática é o uso de um **Jump Server** com regras explícitas.

#### Exemplo de caso prático:
- Criar um Jump Server com IP fixo (ex: `192.168.100.10`)
- Permitir RDP e SSH **somente** deste IP
- Bloquear todo o restante com regras de `Traffic Filtering`

#### Recomendado:
- Integrar o Jump Server com **RADIUS + MFA**
- Utilizar **RDP Gateway** com autenticação de dois fatores

#### Caminho:
```
vSphere Client > Networking > Distributed Port Group > Configure > Traffic Filtering and Marking
```

🔐 Isso ajuda a evitar acesso lateral não autorizado dentro da rede virtualizada.

### 4. 🧱 Configuração do **Firewall no vCenter Server**

Aplicar regras no próprio vCenter para restringir quem pode acessá-lo.

#### Regras sugeridas:
- Permitir apenas IPs de administradores e sistemas autorizados, como ferramentas de backup, monitoramento, hosts ESXi e jump servers
  - `Allow: 10.10.10.100/32`
  - `Allow: 10.10.10.101/32`
- Regra final:
  - `Deny: 0.0.0.0/0`

#### Caminho:
```
vSphere Client > vCenter > Configure > Networking > Firewall Rules (ou appliance CLI)
```

✅ Em vCenter Appliance (VCSA), você pode usar também:
```
/usr/bin/firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=10.10.10.100/32 accept'
```

5. 🧩 Aplicar configurações via Host Profile
Host Profiles são uma maneira eficaz de garantir que todos os hosts ESXi no ambiente estejam configurados conforme as políticas de segurança e conformidade.

Como configurar via vSphere Client:
Vá até vSphere Client > Home > Host Profiles.

Selecione ou crie um Host Profile a partir de um host de referência.

Aplique o Host Profile aos hosts do cluster para garantir configurações consistentes.

Recomendações:
Auditoria e conformidade: Sempre audite os hosts periodicamente para verificar a conformidade com as políticas de segurança e hardening.

Automação: Use o vSphere Auto Deploy para implantar hosts com configurações já aplicadas via Host Profiles.

6. 🚫 Desabilitar ESXi Shell e SSH quando não estiverem em uso
Para minimizar o risco de acesso não autorizado, desabilite o ESXi Shell e o SSH quando não forem necessários.

Como desabilitar via vSphere Client:
Vá até vSphere Client > Host > Configure > System > Advanced System Settings.

Procure por Config.HostAgent.plugins.solo.enableShell e defina o valor como false.

Como desabilitar via CLI:
bash
Copiar
# Desabilitar SSH
esxcli system ssh stop
esxcli system settings advanced set -o /UserVars/ESXiShellTimeOut -i 0

# Desabilitar ESXi Shell
esxcli system settings advanced set -o /UserVars/ESXiShell -i 0
7. ⚙️ Desabilitar serviços desnecessários no ESXi
Reduza a superfície de ataque desabilitando os serviços que não são necessários no ambiente.

Serviços comuns a desabilitar:
SNMP: Desabilitar se não for usado para monitoramento.

vFlash: Se não for utilizado, pode ser desabilitado para reduzir a superfície de ataque.

Fibre Channel: Desabilite se não for necessário para a infraestrutura.

Como desabilitar via vSphere Client:
Vá até vSphere Client > Host > Configure > System > Services.

Selecione os serviços não necessários e clique em Stop.

8. 📝 Configurar syslog remoto no ESXi
Configurar o syslog remoto é uma prática essencial para centralizar logs de eventos e facilitar a auditoria e monitoramento.

Como configurar via vSphere Client:
Vá até vSphere Client > Host > Configure > System > Advanced System Settings.

Altere a variável Syslog.global.logHost para o endereço do servidor de syslog (ex: udp://192.168.1.100:514).

Exemplo de configuração via CLI:
bash
Copiar
esxcli system syslog config set --loghost='udp://192.168.1.100:514'
9. 👥 Aplicar RBAC corretamente no vCenter
A implementação de RBAC (Role-Based Access Control) permite gerenciar com precisão quem tem acesso a quais recursos dentro do vCenter, limitando privilégios de acordo com o papel de cada usuário.

Como configurar via vSphere Client:
Vá até vSphere Client > vCenter > Configure > Permissions.

Crie ou edite as permissões de usuário, atribuindo papéis adequados a cada usuário ou grupo de usuários.

Recomendações:
Papel mínimo necessário: Certifique-se de que os usuários tenham apenas as permissões necessárias para realizar suas tarefas.

Auditoria de acesso: Realize auditorias regulares nas permissões para garantir que os privilégios não sejam excessivos.

10. 👤 Remover contas locais genéricas ou não rastreáveis
É fundamental remover ou desabilitar contas locais genéricas, como root, que não podem ser auditadas, ou que não têm um propósito claramente definido.

Como remover contas locais via vSphere Client:
Vá até vSphere Client > Host > Configure > System > Users.

Selecione as contas não necessárias e remova ou desabilite.

Recomendações:
Utilizar contas baseadas em AD ou LDAP sempre que possível, para centralizar e auditar o gerenciamento de usuários.

Documentação de contas: Mantenha uma lista de todas as contas e seus privilégios para facilitar auditorias.

11. 📢 Habilitar login banner (aviso legal)
O login banner exibe uma mensagem legal ou de segurança antes de permitir o login, avisando os usuários sobre as políticas de segurança.

Como configurar:
No vSphere Client, vá até Host > Configure > System > Security Profile.

Edite as configurações de login banner e adicione uma mensagem apropriada.

Exemplo de mensagem de banner:
makefile
Copiar
Aviso: Este sistema é propriedade da [Nome da Empresa]. O acesso é permitido apenas para usuários autorizados. Qualquer acesso não autorizado é estritamente proibido e será punido por lei.
12. 🔐 Substituir certificados autoassinados por certificados válidos
Para aumentar a segurança, substitua os certificados autoassinados por certificados válidos emitidos por uma Autoridade Certificadora (CA) confiável.

Como substituir:
Obtenha um certificado válido de uma CA confiável.

Vá até vSphere Client > Host > Configure > System > Certificates para importar o novo certificado.

Exemplo de configuração via CLI:
bash
Copiar
# Substituir o certificado no ESXi
esxcli system certs install --cert-file=/path/to/valid-cert.pem --key-file=/path/to/valid-cert-key.pem
13. 🌐 Isolamento de redes técnicas
Isolar redes de gerenciamento, vMotion, vSAN e outras redes técnicas para evitar tráfego indesejado e melhorar a segurança geral.

Como configurar via vSphere Client:
Vá até Networking > Distributed Switch > Configure.

Crie VLANs separadas para cada uma das redes (ex: vMotion, vSAN, Management).

14. 🚨 Auditoria e Logs
Configuração de logs detalhados: Certifique-se de que logs detalhados sejam gerados para todas as ações administrativas.

Envio para um servidor syslog remoto: Centralize os logs para facilitar auditoria e resposta a incidentes.

15. ⚡ Atualizações de Segurança e Patches
Mantenha o ESXi e vCenter sempre atualizados com os patches de segurança mais recentes.

Configurar Auto-Update: Se possível, configure o auto-update para aplicar patches automaticamente no ESXi.

