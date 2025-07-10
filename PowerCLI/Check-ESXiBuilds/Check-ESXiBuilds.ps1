param (
    [Parameter(Mandatory = $true)]
    [string]$Version7,

    [Parameter(Mandatory = $true)]
    [string]$Build7,

    [Parameter(Mandatory = $true)]
    [string]$Version8,

    [Parameter(Mandatory = $true)]
    [string]$Build8,

    [string]$ExportPath = ".\esxi_build_report.csv"
)

# Obter os hosts e suas versões e builds
$hosts = Get-VMHost | Select-Object Name, Version, Build

# Inicializar variáveis para contagem e lista de resultados
$results = @()
$esxi703_red = 0
$esxi803_red = 0
$esxi703_green = 0
$esxi803_green = 0

# Iterar sobre cada host
foreach ($vmHost in $hosts) {
    $result = New-Object PSObject -property @{
        Name    = $vmHost.Name
        Version = $vmHost.Version
        Build   = $vmHost.Build
        Status  = ""
    }

    if ($vmHost.Version -eq $Version7) {
        if ($vmHost.Build -eq $Build7) {
            $result.Status = "Última Build"
            $esxi703_green++
        } else {
            $result.Status = "Não está na última Build"
            $esxi703_red++
        }
    } elseif ($vmHost.Version -eq $Version8) {
        if ($vmHost.Build -eq $Build8) {
            $result.Status = "Última Build"
            $esxi803_green++
        } else {
            $result.Status = "Não está na última Build"
            $esxi803_red++
        }
    }

    $results += $result

    $color = if ($result.Status -eq "Última Build") { "Green" } else { "Red" }
    Write-Host "$($result.Name) - Version: $($result.Version) (Build: $($result.Build)) - $($result.Status)" -ForegroundColor $color
}

# Contagem final
Write-Host "`nQuantidade de Hosts que não estão na última versão da 7.0.3: $esxi703_red"
Write-Host "Quantidade de Hosts que não estão na última versão da 8.0.3: $esxi803_red"
Write-Host "Quantidade de Hosts que estão na última build 7.0.3: $esxi703_green"
Write-Host "Quantidade de Hosts que estão na última build 8.0.3: $esxi803_green"

# Exportar resultado
$results | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8 -Force
Write-Host "`nResultados exportados para o CSV em: $ExportPath"
