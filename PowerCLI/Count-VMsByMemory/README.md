# Count-VMsByMemory.ps1

Script PowerShell com PowerCLI para contar máquinas virtuais com um padrão de nome e quantidade de memória RAM específica.

## 🎯 Objetivo

Facilitar a auditoria ou planejamento de capacidade, identificando rapidamente quantas VMs com uma determinada configuração de memória estão presentes no ambiente.

## 📦 Requisitos

- PowerShell 5.1 ou superior
- Módulo `VMware.PowerCLI`
- Conexão ativa com vCenter (`Connect-VIServer`)

## 🚀 Como usar

```powershell
.\Count-VMsByMemory.ps1 -NamePattern "VMs*" -MemoryGB 4
