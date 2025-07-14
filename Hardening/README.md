# 🛡️ VMware Hardening Guide

Este repositório centraliza práticas recomendadas de hardening para ambientes VMware ESXi e vCenter, com foco em segurança sem custo adicional e aplicável a ambientes corporativos de pequeno a grande porte.

> ⚙️ As configurações descritas aqui devem ser **padronizadas via Host Profile** sempre que possível, garantindo conformidade entre hosts, facilidade de auditoria e agilidade na remediação.

---

## ✅ Pré-requisitos

- Hosts VMware ESXi com vCenter Server para gerenciamento centralizado  
- Acesso ao **vSphere Client (HTML5)** com permissões administrativas

---

## 🔐 Hardening de VMware ESXi e vCenter

### 1. 🔒 Habilitar **Lockdown Mode** (modo estrito)

O **Lockdown Mode** limita os métodos pelos quais o host ESXi pode ser administrado diretamente, forçando a administração a ser feita exclusivamente via **vCenter**.

#### Modos disponíveis:

| Modo     | Acesso SSH | Acesso DCUI (console físico) | Exceções via "Exception Users" |
|----------|------------|------------------------------|--------------------------------|
| Normal   | Negado     | Permitido                    | Permitido                      |
| Strict   | Negado     | **Negado**                   | Permitido                      |

#### Recomendado:
- Ativar o Lockdown Mode em **modo Strict**
- Criar um usuário técnico de exceção com permissões mínimas (ex: `svc-esxi-access`)
- Adicionar esse usuário à lista de **Exception Users** no host
- **Desativar o serviço DCUI** para impedir acesso físico mesmo via console remoto (iDRAC/iLO)
- **Essas configurações podem ser aplicadas e padronizadas via Host Profile para todos os hosts do cluster**

#### Caminho para ativar Lockdown Mode:
```
vSphere Client > Host > Configure > System > Security Profile > Edit > Enable Lockdown Mode (Strict)
```

#### 🔐 Sobre DCUI e interfaces de gerenciamento remoto (iDRAC, iLO)

Mesmo com o Lockdown Mode ativado, o acesso **físico ou virtual** ao console via iDRAC, iLO ou IPMI ainda permite acesso ao **DCUI (Direct Console User Interface)**, que é executado diretamente no host.

⚠️ Para que o modo **Strict** seja verdadeiramente seguro, é necessário **desativar manualmente o DCUI**.

#### Desativar DCUI (via vSphere Client):
```
vSphere Client > Host > Configure > System > Services > Direct Console UI > Stop
```
Em seguida, clique em **"Policy"** e selecione:  
`Start and stop manually`

#### Desativar DCUI (via shell):
```
esxcli system settings advanced set -o /UserVars/ESXiShellTimeOut -i 0
esxcli system settings advanced set -o /UserVars/DCUI -i 0
/etc/init.d/DCUI stop
```

#### 🛠️ Se for necessário reativar o DCUI:

**Via vSphere Client:**
```
vSphere Client > Host > Configure > System > Services > Direct Console UI > Start
```

**Via shell/SSH:**
```
/etc/init.d/DCUI start
```

> 🧠 Recomendações adicionais:
> - Aplique controle de acesso com senha forte e 2FA na iDRAC/iLO  
> - Audite periodicamente o uso do console remoto com ferramentas como **Graylog**, **Aria Operations for Logs** ou outro SIEM integrado  
> - Monitore eventos de ativação do DCUI e alterações no Lockdown Mode

---

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

> ⚠️ Importante: caso a lista de IPs permitidos para um serviço esteja vazia, ele ficará acessível para qualquer origem. Preencha sempre explicitamente os IPs autorizados para cada serviço crítico.

---

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

> 🔐 Isso ajuda a evitar acesso lateral não autorizado dentro da rede virtualizada.

---

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

> ✅ Em vCenter Appliance (VCSA), você pode usar também:
```
/usr/bin/firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=10.10.10.100/32 accept'
```

---

🔜 Em breve:
- SSH e ESXi Shell  
- Serviços desnecessários  
- RBAC e contas padrão  
- Syslog remoto  
- Certificados válidos e banners de login  

---

👷‍♂️ Contribuições são bem-vindas!  