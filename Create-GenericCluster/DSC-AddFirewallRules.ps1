param
(
	[Parameter(Mandatory=$True)]
	[ValidateRange(0,65535)]
	[Int] $CNSPort
)
try 
{
	New-NetFirewallRule -DisplayName "CNS_port_TCP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort $CNSPort -Profile Public
	New-NetFirewallRule -DisplayName "CNS_port_UDP" -Direction Inbound -Action Allow -Protocol UDP -LocalPort $CNSPort -Profile Public
	
	Write-Host "Open CNS port in firewall complete"
}
catch
{
	Write-Host "Open CNS port in firewall failed"
	Write-Error -Message $_.Exception.Message
    throw $_.Exception
}