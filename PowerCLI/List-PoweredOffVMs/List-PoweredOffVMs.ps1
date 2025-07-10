param (
    [string[]]$ClusterNames
)

# Lista VMs desligadas nos clusters informados
Get-Cluster -Name $ClusterNames | Get-VM | Where-Object { $_.PowerState -eq 'PoweredOff' }
