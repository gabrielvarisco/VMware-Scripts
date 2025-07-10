💡 Como usar o script
.\Check-ESXiBuilds.ps1 `
    -Version7 "7.0.3" -Build7 "24585291" `
    -Version8 "8.0.3" -Build8 "24118393" `
    -ExportPath "C:\Relatorios\esxi_builds.csv"


### 📄 Script: Check-ESXiBuilds.ps1

#### 📌 Descrição
Verifica quais hosts ESXi estão com as versões e builds esperadas (atualmente para ESXi 7.0.3 e 8.0.3), e exporta um relatório com o status de conformidade.

#### 🧪 Exemplo de uso
```powershell
.\Check-ESXiBuilds.ps1 `
  -Version7 "7.0.3" -Build7 "24585291" `
  -Version8 "8.0.3" -Build8 "24118393" `
  -ExportPath "C:\Relatorios\esxi_builds.csv"
