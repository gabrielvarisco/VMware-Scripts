[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$NamePattern,

    [Parameter(Mandatory = $true)]
    [string]$CurrentStoragePolicy,

    [Parameter(Mandatory = $true)]
    [string]$NewStoragePolicy
)

$vms = Get-VM | Where-Object { $_.Name -like $NamePattern }

foreach ($vm in $vms) {
    $hardDisks = Get-HardDisk -VM $vm

    foreach ($disk in $hardDisks) {
        $config = Get-SpbmEntityConfiguration -Entity $disk

        if ($config.StoragePolicy.Name -like $CurrentStoragePolicy) {
            Write-Host "Alterando Storage Policy do disco '$($disk.Name)' da VM '$($vm.Name)' de '$($config.StoragePolicy.Name)' para '$NewStoragePolicy'" -ForegroundColor Cyan
            Set-SpbmEntityConfiguration -Entity $disk -StoragePolicy $NewStoragePolicy -Confirm:$false
        }
    }
}