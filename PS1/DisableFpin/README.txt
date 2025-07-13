# Set-FPIN.ps1

Automatize a desativação do recurso **FPIN (Fabric Performance Impact Notification)** em múltiplos hosts **VMware ESXi**, de forma segura e controlada, utilizando PowerShell e SSH.

Este script conecta-se sequencialmente a cada host ESXi listado em um arquivo `hosts.txt`, executando o comando:

esxcli storage fpin info set -e false
Objetivo
Reduzir esforço operacional e garantir consistência na aplicação de configuração FPIN em ambientes VMware, eliminando a necessidade de acesso manual a cada host.

Requisitos
PowerShell (Windows 10+ ou Windows Server 2016+)
PuTTY (plink.exe) instalado
Acesso SSH habilitado nos hosts ESXi
Usuário com permissões administrativas (ex: root)

Set-FPIN/
├── Set-FPIN.ps1         # Script principal
├── hosts.txt            # Lista de hosts ESXi (um por linha)
└── README.md            # Documentação

hosts.txt – Exemplo
192.168.1.200
esxi01.corp.local
192.168.1.21

Execução
Edite hosts.txt com os hosts desejados.

Certifique-se de que plink.exe está localizado em:
C:\Program Files\PuTTY\plink.exe
(Altere o caminho no script, se necessário.)

Execute o script no PowerShell como administrador:

.\Set-FPIN.ps1
Insira as credenciais quando solicitado. O mesmo par usuário/senha será reutilizado para todos os hosts da lista.

Sobre o Comando
O comando esxcli storage fpin info set -e false desativa o FPIN, recurso voltado a gerenciamento de eventos de congestionamento em SANs Fibre Channel. É comum desativá-lo em ambientes onde o comportamento padrão do FPIN interfere na operação esperada.