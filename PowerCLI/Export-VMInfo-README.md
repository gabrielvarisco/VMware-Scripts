💡 Como usar

.\\Export-VMInfo.ps1 -VMNames "VM-Test01", "VM-Test02", "VM-Dev03"





Ou pode carregar de um CSV e passar como parâmetro:

$vms = Import-Csv -Path "C:\\lista.csv" | Select-Object -ExpandProperty VMName

.\\Export-VMInfo.ps1 -VMNames $vms -ExportPath "C:\\Relatorio\_Teste.csv"







\### 📄 Script: Export-VMInfo.ps1



\#### 📌 Descrição

Coleta informações detalhadas de uma ou mais VMs, incluindo estado, recursos, datastores, IPs, atributos personalizados (Custom Attributes), e exporta para um arquivo CSV.



\#### 🧪 Exemplo de uso

```powershell

.\\Export-VMInfo.ps1 -VMNames "VM-Test01", "VM-Test02" -ExportPath "C:\\Relatorio\_Teste.csv"



