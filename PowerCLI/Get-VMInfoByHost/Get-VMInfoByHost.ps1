param (
    [Parameter(Mandatory = $true)]
    [string]$VMHostName,

    [string]$ExportPath = "$env:USERPROFILE\Documents\Relatorio_VMs_$($VMHostName).csv"
)

# Pega o host físico
$vmhost = Get-VMHost -Name $VMHostName -ErrorAction Stop

# Pega todas as VMs associadas ao host
$vms = Get-VM | Where-Object { $_.VMHost -eq $vmhost }

# Lista fixa de Custom Attributes desejados
$customAttrs = @(
    "Application name",
    "Time",
    "Tipo da aplicacao",
    "VRM Owner"
)

# Lista para armazenar os resultados
$result = @()

foreach ($vm in $vms) {
    $vmView = Get-View -Id $vm.Id

    # Informações principais da VM
    $info = [ordered]@{
        VMName        = $vm.Name
        PowerState    = $vm.PowerState
        CPUs          = $vm.NumCpu
        MemoryGB      = $vm.MemoryGB
        GuestOS       = $vm.Guest.OSFullName
        VMHost        = $vm.VMHost.Name
        Cluster       = (Get-Cluster -VM $vm).Name
        IPAddress     = ($vm.Guest.IPAddress -join ", ")
        ProvisionedGB = [math]::Round($vm.ProvisionedSpaceGB, 2)
        UsedSpaceGB   = [math]::Round($vm.UsedSpaceGB, 2)
        DiskCount     = ($vm | Get-HardDisk).Count
        DiskTotalGB   = ($vm | Get-HardDisk | Measure-Object -Property CapacityGB -Sum).Sum
        UUID          = $vmView.Config.Uuid
        CreatedDate   = $vmView.Config.CreateDate
    }

    # Adiciona os atributos personalizados definidos
    foreach ($attr in $customAttrs) {
        $val = (Get-Annotation -Entity $vm -CustomAttribute $attr -ErrorAction SilentlyContinue).Value
        $info[$attr] = $val
    }

    # Adiciona ao array final
    $result += New-Object PSObject -Property $info
}

# Selecionar colunas desejadas
$selectedColumns = @(
    "VMName", "PowerState", "CPUs", "MemoryGB", "VMHost", "Cluster", "IPAddress",
    "Application name", "Time", "Tipo da aplicacao", "VRM Owner"
)

# Exporta para CSV
try {
    $result | Select-Object $selectedColumns | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
    Write-Host "✅ Relatório exportado com sucesso para: $ExportPath"
} catch {
    Write-Error "❌ Erro ao exportar CSV: $_"
}

# Exibe na tela também
$result | Select-Object $selectedColumns | Format-Table -AutoSize
