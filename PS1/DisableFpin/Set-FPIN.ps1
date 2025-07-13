
# Caminho para o arquivo com os hosts ESXi
$hostList = Get-Content -Path "C:\Scripts\hosts.txt"

# Credenciais para login SSH (usuário root ou com permissão para esxcli)
$creds = Get-Credential

foreach ($esxi in $hostList) {
    Write-Host "Conectando ao host: $esxi"

    try {
        # Abrir sessão SSH usando as credenciais
        $user = $creds.UserName
        $pass = $creds.GetNetworkCredential().Password

        # Usar Plink (PuTTY) para enviar o comando remoto via SSH
        $plinkPath = "C:\Program Files\PuTTY\plink.exe"

        if (-Not (Test-Path $plinkPath)) {
            Write-Host "Plink não encontrado em $plinkPath. Instale o PuTTY e tente novamente."
            break
        }

        $cmd = "$plinkPath -ssh $user@$esxi -pw $pass esxcli storage fpin info set -e false"
        Invoke-Expression $cmd

        Write-Host "FPIN desativado com sucesso em $esxi"
    }
    catch {
        Write-Host "Erro ao processar $esxi: $_"
    }
}
