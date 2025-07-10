<<<<<<< HEAD
# vmware-scripts

Scripts PowerCLI, automações vSphere e comandos para ambientes VMware







\# Scripts PowerCLI



Esta pasta contém scripts PowerCLI organizados em subpastas, cada uma com seu próprio script e README específico.



\## Como usar



\- Navegue até a subpasta do script desejado.

\- Leia o README.md localizado nessa subpasta para instruções de uso, parâmetros e exemplos.

\- Execute os scripts no PowerShell com o VMware PowerCLI instalado e conexão válida ao vCenter ou hosts ESXi.



\## Requisitos



\- VMware PowerCLI instalado.

\- Permissões apropriadas no ambiente VMware.

\- Conexão ativa com o vCenter ou ESXi.



\## Observações



Mantenha os scripts atualizados e revise-os antes da execução em ambientes produtivos para evitar impactos inesperados.



---



Para sugestões ou dúvidas, abra uma issue neste repositório.



=======
# Scripts PowerCLI VMware

Este repositório contém uma coleção de scripts PowerCLI para automação e gerenciamento de ambientes VMware vSphere.

---

## Como usar

1. **Conecte-se ao seu ambiente vCenter/ESXi**
Connect-VIServer -Server seu-vcenter -Credential (Get-Credential)

2. Execute o script desejado
Navegue até a pasta powercli e execute o script passando os parâmetros necessários:
.\NomeDoScript.ps1 -Parâmetro1 Valor1 -Parâmetro2 Valor2
>>>>>>> 5f3e836aba7066e58f13285ca0597e0bce318f98
