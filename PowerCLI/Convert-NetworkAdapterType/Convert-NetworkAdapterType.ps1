[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Name
)

$vms = Get-VM -Name $Name -ErrorAction SilentlyContinue

if (!$vms) {
    Write-Warning "Nenhuma VM encontrada com o nome/padrão '$Name'."
    return
}

foreach ($vm in $vms) {
    if ($vm.PowerState -ne "PoweredOff") {
        Write-Warning "VM '$($vm.Name)' está ligada. Desligue antes de alterar o tipo de adaptador de rede."
        continue
    }

    $adapters = Get-NetworkAdapter -VM $vm | Where-Object { $_.Type -eq "E1000" }

    foreach ($adapter in $adapters) {
        Write-Host "Convertendo adaptador '$($adapter.Name)' da VM '$($vm.Name)' para VMXNET3..." -ForegroundColor Cyan
        Set-NetworkAdapter -NetworkAdapter $adapter -Type "vmxnet3" -Confirm:$false
    }
}