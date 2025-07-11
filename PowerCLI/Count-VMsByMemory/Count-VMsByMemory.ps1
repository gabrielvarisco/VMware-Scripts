[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$NamePattern,

    [Parameter(Mandatory = $true)]
    [int]$MemoryGB
)

$vms = Get-VM | Where-Object {
    $_.Name -like $NamePattern -and $_.MemoryGB -eq $MemoryGB
}

$vmCount = $vms.Count

Write-Host "Total de VMs com nome '$NamePattern' e $MemoryGB GB de memória: $vmCount" -ForegroundColor Green