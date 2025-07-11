[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$NamePattern,

    [Parameter(Mandatory = $false)]
    [int]$CPUCount,

    [Parameter(Mandatory = $false)]
    [int]$CoresPerSocket
)

# Filtra VMs desligadas conforme padrão
$filteredVMs = Get-VM | Where-Object {
    $_.Name -like $NamePattern -and $_.PowerState -eq "PoweredOff"
}

foreach ($vm in $filteredVMs) {
    if ($CPUCount -and $vm.NumCpu -ne $CPUCount) {
        Write-Host "Ajustando CPU da VM $($vm.Name) para $CPUCount" -ForegroundColor Cyan
        Set-VM -VM $vm -NumCpu $CPUCount -Confirm:$false
    }

    if ($CoresPerSocket -and $vm.CoresPerSocket -ne $CoresPerSocket) {
        Write-Host "Ajustando CoresPerSocket da VM $($vm.Name) para $CoresPerSocket" -ForegroundColor Cyan
        Set-VM -VM $vm -CoresPerSocket $CoresPerSocket -Confirm:$false
    }
}