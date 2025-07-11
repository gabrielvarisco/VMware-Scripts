# Convert-NetworkAdapterType.ps1

Este script PowerShell (com PowerCLI) identifica e converte adaptadores de rede do tipo **E1000** para **VMXNET3** em máquinas virtuais VMware vSphere.

## 🎯 Objetivo

Melhorar o desempenho e compatibilidade de rede de VMs convertendo adaptadores antigos (E1000) para VMXNET3 — recomendado para ambientes modernos com VMware Tools atualizados.

## 📦 Requisitos

- PowerShell 5.1 ou superior
- Módulo `VMware.PowerCLI`
- A VM deve estar **desligada**
- Conexão ativa com vCenter (`Connect-VIServer`)

## 🚀 Como usar

```powershell
.\Convert-NetworkAdapterType.ps1 -Name "VM-NAME"

