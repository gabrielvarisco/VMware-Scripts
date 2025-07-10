param (
    [string[]]$VMHostNames = @()
)

# Obter hosts - todos ou filtrados pelo parâmetro
$hosts = if ($VMHostNames.Count -gt 0) {
    Get-VMHost -Name $VMHostNames
} else {
    Get-VMHost
}

$results = $hosts | Sort-Object Name | Select-Object `
    Name,
    @{Name="NTPServer"; Expression = { ($_ | Get-VMHostNtpServer) -join ", " }},
    @{Name="Timezone"; Expression = { $_.Timezone }},
    @{Name="CurrentTime"; Expression = {
        (Get-View $_.ExtensionData.ConfigManager.DateTimeSystem).QueryDateTime().ToLocalTime()
    }},
    @{Name="ServiceRunning"; Expression = {
        ($_.ExtensionData.ConfigManager.ServiceSystem.ServiceInfo | Where-Object { $_.Key -eq "ntpd" }).Running
    }}

$results | Format-Table -AutoSize
