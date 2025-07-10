param (
    [string]$vmName,
    [string]$targetDatastoreClusterName,
    [string]$transitionHost,
    [string]$destinationHost
)

# Caminho do arquivo de log
$logPath = "D:\Users\$($env:USERNAME)\Migracao_$vmName2.log"

# Função para registrar logs
Function Write-Log {
    param([string]$message)
    Add-Content -Path $logPath -Value "$(Get-Date): $message" -Encoding UTF8
}

# Obter a VM
$vm = Get-VM -Name $vmName
if (-not $vm) {
    Write-Host "Erro: VM '$vmName' não encontrada."
    Write-Log "Erro: VM '$vmName' não encontrada."
    return
}

# Verificar se está no host de transição
if ($vm.VMHost.Name -ne $transitionHost) {
    Write-Host "Movendo a VM '$vmName' para o host de transição '$transitionHost'..."
    Write-Log "Movendo a VM '$vmName' para o host de transição '$transitionHost'."
    Move-VM -VM $vm -Destination (Get-VMHost -Name $transitionHost) -Confirm:$false -RunAsync
    Start-Sleep -Seconds 60
} else {
    Write-Host "A VM '$vmName' já está no host de transição '$transitionHost'."
    Write-Log "A VM '$vmName' já está no host de transição '$transitionHost'. Nenhuma migração será feita."
}

# Obter o Datastore Cluster de destino
$targetCluster = Get-DatastoreCluster -Name $targetDatastoreClusterName
if (-not $targetCluster) {
    Write-Host "Erro: Datastore Cluster '$targetDatastoreClusterName' não encontrado."
    Write-Log "Erro: Datastore Cluster '$targetDatastoreClusterName' não encontrado."
    return
}

# Obter datastores do cluster
$datastoresInCluster = Get-Datastore -RelatedObject $targetCluster

# Obter discos da VM
$disks = Get-VM -Name $vmName | Get-HardDisk | Select-Object Name, StorageFormat,
    @{Name="CapacityGB";Expression={[math]::Round($_.CapacityKB / 1MB, 2)}} ,
    @{Name="Datastore";Expression={($_.Filename -split "\[|\]")[1]}}

$totalDisks = $disks.Count
$remainingDisks = $totalDisks
$allDisksMigrated = $true

foreach ($disk in $disks) {
    $diskName = $disk.Name
    $currentDatastore = $disk.Datastore
    $diskAlreadyInCluster = $datastoresInCluster | Where-Object { $_.Name -eq $currentDatastore }

    if ($diskAlreadyInCluster -and $disk.StorageFormat -eq "Thick") {
        Write-Host "Disco '$diskName' já está em um datastore do cluster de destino ('$currentDatastore') e no formato Thick Provisioned."
        Write-Log "Disco '$diskName' já está em um datastore do cluster de destino ('$currentDatastore') e no formato Thick Provisioned."
        $remainingDisks -= 1
        continue
    }

    # Seleciona o datastore com mais espaço livre
    $targetDatastore = $datastoresInCluster | Sort-Object -Property FreeSpaceGB -Descending | Select-Object -First 1

    Write-Host "Migrando disco '$diskName' para datastore '$($targetDatastore.Name)' como Thick Provisioned..."
    Write-Log "Migrando disco '$diskName' para datastore '$($targetDatastore.Name)'..."

    try {
        $startTime = Get-Date
        $diskToMove = Get-HardDisk -VM $vm | Where-Object { $_.Name -eq $diskName }

        # Atualiza os datastores após cada migração
        $datastoresInCluster = Get-Datastore -RelatedObject $targetCluster

        # Recalcula o melhor datastore
        $targetDatastore = $datastoresInCluster | Sort-Object -Property FreeSpaceGB -Descending | Select-Object -First 1

        # Move o disco
        $task = Move-HardDisk -HardDisk $diskToMove -Datastore $targetDatastore -StorageFormat Thick -Confirm:$false -RunAsync
        $task | Wait-Task
        $duration = (Get-Date) - $startTime

        Write-Host "Disco '$diskName' migrado com sucesso em $duration."
        Write-Log "Disco '$diskName' migrado com sucesso para '$($targetDatastore.Name)' em $duration."

        Start-Sleep -Seconds 20  # Aguarda atualização do espaço livre

        $remainingDisks -= 1
        Write-Host "Discos restantes para migração: $remainingDisks de $totalDisks"
        Write-Log "Discos restantes para migração: $remainingDisks de $totalDisks"
    } catch {
        Write-Host "Erro ao mover o disco '$diskName': $_"
        Write-Log "Erro ao mover o disco '$diskName': $_"
        $allDisksMigrated = $false
    }
}

# Aguardar 60 segundos para garantir o refresh
Start-Sleep -Seconds 60

# Recalcular datastores do cluster após as migrações
$datastoresInCluster = Get-Datastore -RelatedObject $targetCluster
$targetDatastoreNames = ($datastoresInCluster | Select-Object -ExpandProperty Name)

# Verificar se todos os discos estão no cluster correto
$disks = Get-VM -Name $vmName | Get-HardDisk | Select-Object Name,
    @{Name="Datastore";Expression={($_.Filename -split "\[|\]")[1]}}

$allDisksInCluster = $disks | ForEach-Object {
    $targetDatastoreNames -contains $_.Datastore
} | Where-Object { $_ -eq $false } | Measure-Object | Select-Object -ExpandProperty Count

if ($allDisksMigrated -and $allDisksInCluster -eq 0) {
    Write-Host "Todos os discos foram migrados para o Datastore Cluster '$targetDatastoreClusterName'."
    Write-Log "Todos os discos foram migrados para o Datastore Cluster '$targetDatastoreClusterName'."

    Write-Host "Movendo a VM '$vmName' para o novo host '$destinationHost'..."
    Write-Log "Movendo a VM '$vmName' para o novo host '$destinationHost'..."

    try {
        Move-VM -VM $vm -Destination (Get-VMHost -Name $destinationHost) -Confirm:$false -RunAsync
        Write-Host "VM '$vmName' movida com sucesso para o host '$destinationHost'."
        Write-Log "VM '$vmName' movida com sucesso para o host '$destinationHost'."
    } catch {
        Write-Host "Erro ao mover a VM para o host '$destinationHost': $_"
        Write-Log "Erro ao mover a VM para o host '$destinationHost': $_"
    }
} else {
    Write-Host "Erro: Nem todos os discos foram migrados para o Datastore Cluster '$targetDatastoreClusterName'."
    Write-Log "Erro: Nem todos os discos foram migrados para o Datastore Cluster '$targetDatastoreClusterName'."
}