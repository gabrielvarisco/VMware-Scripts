# Set-VMStoragePolicy.ps1

Script PowerShell para alterar a Storage Policy de discos rígidos de VMs VMware vSphere com base em um padrão de nome.

## 🎯 Objetivo

Automatizar a troca de Storage Policy para discos de VMs específicas, facilitando migrações e padronizações em ambientes VMware.

## 📦 Requisitos

- PowerShell 5.1 ou superior
- Módulo VMware.PowerCLI
- Permissões para modificar Storage Policy no vCenter
- Conexão ativa com o vCenter (`Connect-VIServer`)

## 🚀 Como usar

```powershell
.\Set-VMStoragePolicy.ps1 -NamePattern "VMs-NAME*" -CurrentStoragePolicy "vSAN Default Storage Policy" -NewStoragePolicy "POLICY-NAME"
