# migrate-vm-disks-to-cluster.ps1

## 📌 Descrição

Este script PowerCLI realiza a **migração completa dos discos de uma VM** para um **Datastore Cluster**, convertendo os discos para o formato **Thick Provisioned**, caso estejam em Thin. Ele também movimenta a VM entre hosts (transição → destino), com logs detalhados de cada etapa do processo.

---

## ⚙️ Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|----------|------|-------------|-----------|
| `vmName` | string | Sim | Nome da VM a ser migrada |
| `targetDatastoreClusterName` | string | Sim | Nome do Datastore Cluster de destino |
| `transitionHost` | string | Sim | Nome do host intermediário (de transição) |
| `destinationHost` | string | Sim | Nome do host final para onde a VM será movida após a migração |

---

## ▶️ Exemplo de uso

```powershell
.\migrate-vm-disks-to-cluster.ps1 "NomeDaVM" "NomeDoClusterDeDatastore" "nome-do-host-de-transicao.domain" "nome-do-host-final.domain"


📋 Etapas executadas pelo script
Movimentação inicial da VM para o host de transição

Se a VM ainda não estiver no host de transição, ela será movida para lá.

Migração de discos da VM (um por vez)

Para cada disco:

Verifica se já está no Datastore Cluster de destino e se está em formato Thick.

Se não estiver, move o disco para o datastore com maior espaço livre no momento, convertendo para Thick se necessário.

Recalcula os datastores disponíveis a cada disco migrado.

Movimentação final da VM para o host de destino

Se todos os discos foram migrados com sucesso para o cluster, o script tenta mover a VM para o host final.

⚠️ Importante: o VM Home (arquivos de configuração da VM) não é migrado automaticamente nesta etapa. Esta movimentação precisa ser feita manualmente ou com script específico utilizando RelocateVM_Task.

Geração de log

Um arquivo de log é salvo com todos os eventos em:
D:\Users\$env:USERNAME\Migracao_$vmName2.log

📦 Requisitos
VMware PowerCLI instalado

Conexão ativa com o vCenter (Connect-VIServer)

Permissões adequadas para migração de discos e movimentação de VMs

🛠️ Considerações técnicas
Ideal para migrações planejadas entre clusters de armazenamento com validação de local e formato dos discos.

Suporta controle assíncrono (-RunAsync com Wait-Task) para acompanhar a duração real de cada movimentação.

Pode ser adaptado para processar múltiplas VMs em sequência.



