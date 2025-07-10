param (
    [Parameter(Mandatory = $true)]
    [string[]]$VMNames,

    [string]$ExportPath = "C:\Relatorio_VMs.csv"
)

# Pega todos os nomes de Custom Attributes definidos no ambiente
$allCustomAttrNames = Get-CustomAttribute | Select-Object -ExpandProperty Name

# Lista para armazenar os resultados
$result = @()

foreach ($vmName in $VMNames) {
    $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
    if ($vm) {
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

        # Coletar todos os Custom Attributes definidos
        foreach ($attrName in $allCustomAttrNames) {
            $val = (Get-Annotation -Entity $vm -CustomAttribute $attrName -ErrorAction SilentlyContinue).Value
            $info[$attrName] = $val
        }

        # Adiciona o resultado final ao array
        $result += New-Object PSObject -Property $info
    } else {
        Write-Warning "VM '$vmName' não encontrada."
    }
}

# Exportar para CSV
$result | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8

Write-Host "Relatório exportado com sucesso: $ExportPath"
