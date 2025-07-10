Como usar
Para todos os hosts:
.\Check-NtpStatus.ps1

Para hosts específicos:
.\Check-NtpStatus.ps1 -VMHostNames "esxi-host1","esxi-host2"

Explicação dos campos
NTPServer: Servidores NTP configurados no host, obtidos via Get-VMHostNtpServer.
Timezone: Fuso horário configurado no host, obtido da propriedade Timezone.
CurrentTime: Horário atual do host, consultado via QueryDateTime() e convertido para o horário local.
ServiceRunning: Indica se o serviço ntpd está rodando no host.