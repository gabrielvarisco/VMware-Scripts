# PowerCLI Script — Inventário de VMs por Host

Este script PowerShell com PowerCLI coleta informações detalhadas de todas as máquinas virtuais (VMs) hospedadas em um host ESXi específico e exporta os dados para um arquivo CSV, além de exibir um resumo no console.

## 🚀 Funcionalidades

- Lista todas as VMs associadas a um host físico (ESXi)
- Coleta dados como:
  - Estado da VM
  - CPU, memória, IP, SO
  - Tamanho provisionado e usado
  - Quantidade e tamanho total de discos
  - UUID e data de criação
- Inclui atributos personalizados (Custom Attributes):
  - Application name
  - Time
  - Tipo da aplicacao
  - VRM Owner
- Exporta os dados para um arquivo `.csv`
- Exibe o resultado também no terminal

## ✅ Requisitos

- PowerShell
- VMware PowerCLI
- Conexão ativa com o vCenter (`Connect-VIServer`)

## 📦 Como usar

1. Conecte-se ao seu vCenter:

```powershell
Connect-VIServer -Server seu-vcenter

Execute o script informando o nome do host ESXi:
.\Get-VMInfoByHost.ps1 -VMHostName "nome-do-host"
ou
.\Get-VMInfoByHost.ps1 -VMHostName "nome-do-host" -ExportPath "C:\Relatorios\InventarioVMs.csv"

