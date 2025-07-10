param (
    [string[]]$VMNames = @()
)

# Pega as VMs (todas ou as específicas)
$vms = if ($VMNames.Count -gt 0) {
    Get-VM -Name $VMNames
} else {
    Get-VM
}

# Pega os snapshots das VMs filtradas
$snapshots = $vms | Get-Snapshot

if ($snapshots) {
    # Exibe VM e nome do snapshot
    $snapshots | Select-Object @{Name='VMName';Expression={$_.VM.Name}}, Name | Format-Table -AutoSize
    Write-Host "`nTotal de snapshots encontrados: $($snapshots.Count)"
} else {
    Write-Host "Nenhum snapshot encontrado para as VMs especificadas."
}
