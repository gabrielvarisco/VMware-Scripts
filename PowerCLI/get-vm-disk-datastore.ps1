param (
    [Parameter(Mandatory = $true)]
    [string]$VMName
)

# Buscar a VM
$vm = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if (-not $vm) {
    Write-Error "A VM '$VMName' não foi encontrada."
    exit 1
}

# Buscar cluster
$cluster = Get-Cluster -VM $vm

# Coletar discos
$disks = $vm | Get-HardDisk | ForEach-Object {
    [PSCustomObject]@{
        Name      = $_.Name
        Datastore = $_.FileName.Split(']')[0].Trim('[')
    }
}

# Exibir
Write-Host "VMName  : $($vm.Name)"
Write-Host "Cluster : $($cluster.Name)"
Write-Host ""

# Exibir em colunas
$columns = 3
$rows = [math]::Ceiling($disks.Count / $columns)

for ($i = 0; $i -lt $rows; $i++) {
    $line = ""
    for ($j = 0; $j -lt $columns; $j++) {
        $index = $i + ($j * $rows)
        if ($index -lt $disks.Count) {
            $d = $disks[$index]
            $line += ("{0,-20} {1,-35} " -f $d.Name, $d.Datastore)
        }
    }
    Write-Host $line
}
