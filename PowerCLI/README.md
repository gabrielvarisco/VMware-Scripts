# add-new-harddisk-controller.ps1

## O que esse script faz

Adiciona um novo disco rígido virtual (Hard Disk) a uma VM VMware usando PowerCLI, especificando nome da VM, tamanho do disco, datastore e controladora SCSI.

---

## Parâmetros do script

| Parâmetro    | Tipo    | Obrigatório | Descrição                                   | Valor padrão        |
|--------------|---------|-------------|---------------------------------------------|---------------------|
| `-vmName`    | string  | Sim         | Nome da VM onde será adicionado o disco     | —                   |
| `-capacityGB`| int     | Sim         | Tamanho do disco em GB                      | —                   |
| `-datastore` | string  | Sim         | Nome do datastore onde o disco será criado  | —                   |
| `-controller`| string  | Não         | Controladora SCSI para anexar o disco       | `"SCSI controller 0"` |

---

## Requisitos

- VMware PowerCLI instalado  
- Conexão ativa com o vCenter (use `Connect-VIServer` antes de rodar o script)

---

## Como usar

1. Abra o PowerCLI e conecte ao vCenter:

```powershell
Connect-VIServer -Server "seu-vcenter" -User "usuario" -Password "senha"

#Execute o script com os parâmetros desejados:
.\add-new-harddisk-controller.ps1 -vmName "MinhaVM" -capacityGB 50 -datastore "Datastore1"

#Se quiser especificar o controlador SCSI:
.\add-new-harddisk-controller.ps1 -vmName "MinhaVM" -capacityGB 50 -datastore "Datastore1" -controller "SCSI controller 1"

