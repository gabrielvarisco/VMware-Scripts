# Scripts PowerCLI VMware

Este repositório contém uma coleção de scripts PowerCLI para automação e gerenciamento de ambientes VMware vSphere.

---

## Como usar

1. **Conecte-se ao seu ambiente vCenter/ESXi**
Connect-VIServer -Server seu-vcenter -Credential (Get-Credential)

2. Execute o script desejado
Navegue até a pasta powercli e execute o script passando os parâmetros necessários:
.\NomeDoScript.ps1 -Parâmetro1 Valor1 -Parâmetro2 Valor2
