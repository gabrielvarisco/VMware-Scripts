param(
    [Parameter(Mandatory=$true)]
    [string]$vmName,

    [Parameter(Mandatory=$true)]
    [int]$capacityGB,

    [Parameter(Mandatory=$true)]
    [string]$datastore,

    [string]$controller = "SCSI controller 0"
)

$vm = Get-VM -Name $vmName

if ($null -eq $vm) {
    Write-Error "VM '$vmName' não encontrada!"
    return
}

New-HardDisk -VM $vm -CapacityGB $capacityGB -Datastore $datastore -Controller $controller

Write-Host "Disco novo de $capacityGB GB adicionado na VM '$vmName' no datastore '$datastore'."
